#!/bin/bash
usage() {
echo "---"
echo "$0 <hostname where database resides> <database name> <database user> <database password> <gcp project> <gcp bucket> <gcp sql instance> <gcp database> <gcp db user> <service account email> <pg dump flags>"
}

if [ "$#" -lt 9 ]; then
  usage
  exit 1
fi

DB_HOST=$1
DB_NAME=$2
DB_USER=$3
export PGPASSWORD=$4
GCP_PROJECT=$5
GCP_BUCKET=$6
GCP_INSTANCE=$7
GCP_DATABASE=$8
GCP_DB_USER=$9
GCP_SA_EMAIL=$10
PG_DUMP_FLAGS=$11



# dump database
pg_dump -h ${DB_HOST} -d ${DB_NAME} -U ${DB_USER} --format=plain --no-owner --no-acl -Z9 ${PG_DUMP_FLAGS} -v \
	> /data/${DB_NAME}.dmp.gz

# move database dump to bucket
gcloud config set project ${GCP_PROJECT}
gcloud auth activate-service-account --key-file /var/run/secrets/nais.io/migration-user/user
gsutil iam ch serviceAccount:"${GCP_SA_EMAIL}":objectCreator gs://"${GCP_BUCKET}"

service_account_email=$(gcloud sql instances describe ${GCP_INSTANCE} | yq '.serviceAccountEmailAddress')
gsutil iam ch serviceAccount:"${service_account_email}":objectViewer gs://"${GCP_BUCKET}"

gsutil mb gs://"${GCP_BUCKET}" -l EUROPE-NORTH1
gsutil -m -o GSUtil:parallel_composite_upload_threshold=150M cp /data/${DB_NAME}.dmp.gz gs://"${GCP_BUCKET}"/

# import database in gcp
gcloud sql import sql ${GCP_INSTANCE} gs://${GCP_BUCKET}/${DB_NAME}.dmp.gz \
  --database=${GCP_DATABASE} \
  --user=${GCP_DB_USER} \
  --quiet
