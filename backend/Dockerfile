# backend/Dockerfile
# Multi-stage build for SafeChat FastAPI backend on Cloud Run.

# ============================================================
# Stage 1: builder — installs dependencies into an isolated venv
# ============================================================
FROM python:3.11-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# build-essential covers the rare case where a wheel isn't available for a
# given platform; pip prefers prebuilt wheels when present.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy requirements first so dependency layers cache across code changes.
COPY requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip && \
    pip install -r /tmp/requirements.txt

# ============================================================
# Stage 2: runtime — minimal image with just the venv + app code
# ============================================================
FROM python:3.11-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH" \
    PORT=8080

# Non-root user. uid/gid 1000 is a conventional value for app accounts.
RUN groupadd --system --gid 1000 appgroup && \
    useradd --system --uid 1000 --gid appgroup \
    --home-dir /app --shell /sbin/nologin appuser

# Bring in the virtualenv from the builder stage.
COPY --from=builder /opt/venv /opt/venv

WORKDIR /app
COPY --chown=appuser:appgroup . /app

USER appuser

# Documentation only — Cloud Run reads PORT from the env var, not EXPOSE.
EXPOSE 8080

# Shell form so ${PORT} is expanded at runtime (Cloud Run injects PORT).
# `exec` makes gunicorn PID 1 so it receives SIGTERM directly for graceful
# shutdown.
CMD exec gunicorn main:app \
    --bind 0.0.0.0:${PORT} \
    --workers 1 \
    --worker-class uvicorn.workers.UvicornWorker \
    --timeout 60 \
    --access-logfile - \
    --error-logfile -
