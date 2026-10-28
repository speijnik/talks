FROM python:3.14-slim

ARG VERSION=dev
ARG BROKEN=false
ENV APP_VERSION=$VERSION \
    APP_BROKEN=$BROKEN \
    PYTHONUNBUFFERED=1

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py healthcheck.py ./
COPY static/ static/

USER nobody
EXPOSE 8080
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "app:app"]
