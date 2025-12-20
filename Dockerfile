# Stage 1: Builder
# Use a standard Python image with a shell and package manager for building
FROM python:3.14-slim as python-env
FROM heroku/builder:24 as builder-img
FROM buildpacksio/pack:base as builder-pack

ADD . /ce-function

# Stage 1: build image
WORKDIR /ce-function
RUN func build --builder=builder-pack  --image leradicator/ce-function:kn --path=/ce-function --builder-image=builder-img --verbose

# Stage 2: Runtime (Distroless)
# Use Google's official distroless Python image
FROM gcr.io/distroless/python3-debian14:nonroot

# Copy only the necessary files from the builder stage
COPY --from=builder /app /app
# Copy installed Python packages to the appropriate system path
COPY --from=builder /usr/local/lib/python3.14/site-packages /usr/local/lib/python3.14/site-packages

WORKDIR /app

# Define the entrypoint command
CMD ["PORT=8080", "LISTEN_ADDRESS=127.0.0.1:8080", "python", "./service/main.py"]
