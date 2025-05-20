# Use official Python slim image
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    libpq-dev \
    curl \
    netcat-openbsd \
    libssl-dev \
    libffi-dev \
    libsystemd-dev \
    libdbus-1-dev \
    libdbus-glib-1-dev \
    libgirepository1.0-dev \
    libglib2.0-dev \
    gir1.2-gtk-3.0 \
    libcairo2-dev \
    libcups2-dev \
    liblouis-dev \
    python3-gi \
    python3-apt \
    && rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos "" appuser

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:5000/ || exit 1

CMD ["python", "app.py"]
