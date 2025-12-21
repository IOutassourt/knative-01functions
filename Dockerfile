# Stage 1: Builder
# Use a standard Python image with a shell and package manager for building
FROM python:3.14-slim as python-env
#FROM heroku/builder:24 as builder
#FROM buildpacksio/pack:base as pack

# ---- Environment ----
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080 \
    POETRY_VERSION=1.8.3 \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=false

# ---- System deps ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# ---- Poetry install ----
RUN curl -sSL https://install.python-poetry.org | python3 - \
    && ln -s /root/.local/bin/poetry /usr/local/bin/poetry

WORKDIR /app

# ---- Dependency layer (Tekton cache-friendly) ----
COPY pyproject.toml poetry.lock* ./

RUN pip install --no-cache-dir .

# ---- App code ----
COPY . .

# ---- Non-root user ----
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8080

ENV PORT=8080
ENV LISTEN_ADDRESS=0.0.0.0:8080

# ---- Runtime ----
CMD ["python", "./service/main.py"]
