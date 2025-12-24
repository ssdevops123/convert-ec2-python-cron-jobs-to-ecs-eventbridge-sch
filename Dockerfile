FROM python:3.9-slim

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    build-essential \
    libpq-dev \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Copy code
# COPY notifiers /notifiers/
COPY . /notifiers/

# Enable imports
ENV PYTHONPATH="/notifiers"

# Install dependencies
COPY requirements.txt /
RUN pip install --no-cache-dir -r /requirements.txt

# Logs dir
RUN mkdir -p /opt/recupe/notifiers/logs
# RUN mkdir -p /notifiers/logs 

# Set correct working directory
WORKDIR /notifiers


# Run module properly
CMD ["python3", "-m", "notifier.push_notifiers.medication_notification"]
