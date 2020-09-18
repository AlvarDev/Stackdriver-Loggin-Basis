# Get project information
export PROJECT_ID=$(gcloud config list \
  --format 'value(core.project)')
export PROJECT_NUMBER=$(gcloud projects list \
  --filter="$PROJECT_ID" \
  --format="value(PROJECT_NUMBER)")

# Enable services on GCP project
gcloud services enable logging.googleapis.com

# Creating a Service Account for our API
gcloud iam service-accounts create logging-basis-cred \
  --description "Service Account for Logging Basis Service" \
  --display-name "Logging Basis Service Account"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:logging-basis-cred@$PROJECT_ID.iam.gserviceaccount.com \
  --role="roles/logging.logWriter"

gcloud iam service-accounts keys create \
  --iam-account logging-basis-cred@$PROJECT_ID.iam.gserviceaccount.com logging-basis-cred.json

# For CI/CD you can encrypt this service account
# using KMS (https://cloud.google.com/security-key-management).

# NEVER save a service account on a repository.

gcloud auth configure-docker

docker build -t gcr.io/$PROJECT_ID/logging-basis:v0.1 .

docker push gcr.io/$PROJECT_ID/logging-basis:v0.1

gcloud run deploy logging-basis \
  --image gcr.io/$PROJECT_ID/logging-basis:v0.1 \
  --region us-east1 \
  --platform managed \
  --allow-unauthenticated

