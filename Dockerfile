# ---- Stage 1: builder ----
# Install Python dependencies into an isolated virtualenv that we copy later.
# Keeping pip/build steps in a separate stage means the final image does not
# carry build caches or tooling it doesn't need at runtime.
FROM python:3.12-slim AS builder

WORKDIR /app

COPY requirements.txt .
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir -r requirements.txt

# ---- Stage 2: runtime ----
# Final image: only the venv + app code, no build tools. Runs as non-root.
FROM python:3.12-slim AS runtime

# Create an unprivileged user so the app never runs as root inside the container.
RUN useradd --create-home --uid 10001 appuser

WORKDIR /app

# Bring over the ready-made virtualenv from the builder stage.
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy only the application code.
COPY app.py .

# Drop root: every command from here runs as 'appuser'.
USER appuser

# Document that the container listens on 8080 (informational only).
EXPOSE 8080
ENV PORT=8080

# Start gunicorn (a production WSGI server) instead of Flask's dev server.
# `exec` makes gunicorn replace the shell as PID 1, so it receives SIGTERM
# directly and shuts down gracefully when Kubernetes stops the pod.
CMD ["sh", "-c", "exec gunicorn --bind 0.0.0.0:${PORT} --workers 2 app:app"]
