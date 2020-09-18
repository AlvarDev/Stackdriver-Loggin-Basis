FROM python:3.7.5-slim

COPY requirements.txt requirements.txt

RUN pip3 install --trusted-host pypi.python.org -r requirements.txt

COPY . /app

WORKDIR /app

# Credentials
ENV GOOGLE_APPLICATION_CREDENTIALS=logging-basis-cred.json

# Stackdriver Loggin settings
ENV SERVICE=logging-basis

ENV REGION=us-east1

ENV RESOURCE_TYPE=cloud_run_revision

EXPOSE 8080

ENTRYPOINT ["gunicorn", "-b", "0.0.0.0:8080", "main:app"]