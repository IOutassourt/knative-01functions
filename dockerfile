# Stage 1: Builder
# Use a standard Python image with a shell and package manager for building
FROM python:3.12-slim as builder
WORKDIR /app

# Install application dependencies (e.g., from requirements.txt)
COPY requirements.txt .
RUN pip install --trusted-host pypi.org --no-cache-dir -r requirements.txt

COPY . .

# Stage 2: Runtime (Distroless)
# Use Google's official distroless Python image
FROM gcr.io/distroless/python3-debian12:nonroot

# Copy only the necessary files from the builder stage
COPY --from=builder /app /app
# Copy installed Python packages to the appropriate system path
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages

WORKDIR /app

# Define the entrypoint command
CMD ["PORT=8080", "LISTEN_ADDRESS=127.0.0.1:8080", "python", "./service/main.py"]
