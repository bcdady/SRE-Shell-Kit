#!/usr/bin/env bash

# Pseudo code for this script:
# 1. Generate IAM credential reports for multiple AWS accounts via AWS cli
# 1. a. aws iam generate-credential-report
# 2. Get the generated IAM credential reports for each AWS accounts via AWS cli
# 2. a. Parse downloaded content to CSV format

# make output directories, just in case
mkdir -p credential-report-request
mkdir -p credential-reports

# 1. Generate IAM credential reports. Write request response to json
echo "generate-credential-report: sap-main"
aws --profile bryan iam generate-credential-report > ./credential-report-request/sap-main.json
echo "generate-credential-report: sap-main"
aws --profile cbt iam generate-credential-report > ./credential-report-request/cbt.json
echo "generate-credential-report: sap-main"
aws --profile cca iam generate-credential-report > ./credential-report-request/cca.json
echo "generate-credential-report: sap-main"
aws --profile cde iam generate-credential-report > ./credential-report-request/cde.json
echo "generate-credential-report: sap-main"
aws --profile data iam generate-credential-report > ./credential-report-request/data.json
echo "generate-credential-report: sap-main"
aws --profile experiment iam generate-credential-report > ./credential-report-request/experiment.json
echo "generate-credential-report: sap-main"
aws --profile fluro iam generate-credential-report > ./credential-report-request/fluro.json
echo "generate-credential-report: sap-main"
aws --profile giving iam generate-credential-report > ./credential-report-request/giving.json
echo "generate-credential-report: sap-main"
aws --profile infra iam generate-credential-report > ./credential-report-request/infra.json
echo "generate-credential-report: sap-main"
aws --profile nonprod iam generate-credential-report > ./credential-report-request/sap-nonprod.json
# aws --profile sap iam generate-credential-report > ./credential-report-request/sap.json
echo "generate-credential-report: sap-main"
aws --profile snappages iam generate-credential-report > ./credential-report-request/snappages.json
echo "generate-credential-report: sap-main"
aws --profile stage iam generate-credential-report > ./credential-report-request/sap-stage.json
echo "generate-credential-report: sap-main"
aws --profile stream iam generate-credential-report > ./credential-report-request/streamspot.json
echo "generate-credential-report: sap-main"
aws --profile stream-stage iam generate-credential-report > ./credential-report-request/streamspot-stage.json
echo "generate-credential-report: sap-main"
aws --profile twomites iam generate-credential-report > ./credential-report-request/twomites.json

# 2. Get the generated IAM credential report contents
# JSON contains the credential report; Base64 encoded.
echo "getting and parsing credential-report: sap-main"
aws --profile bryan iam get-credential-report | jq -r .Content | base64 -d > credential-reports/credentials_sap-main.csv
echo "getting and parsing credential-report: sap-main"
aws --profile cbt iam get-credential-report | jq -r .Content | base64 -d > credential-reports/credentials_cbt.csv
echo "getting and parsing credential-report: sap-main"
aws --profile cca iam get-credential-report | jq -r .Content | base64 -d > credential-reports/credentials_cca.csv
echo "getting and parsing credential-report: sap-main"
aws --profile cde iam get-credential-report | jq -r .Content | base64 -d > credential-reports/credentials_cde.csv
echo "getting and parsing credential-report: sap-main"
aws --profile data iam get-credential-report | jq -r .Content | base64 -d > credential-reports/credentials_data.csv
echo "getting and parsing credential-report: sap-main"
aws --profile experiment iam get-credential-report | jq -r .Content | base64 -d > credential-reports/credentials_experiment.csv
echo "getting and parsing credential-report: sap-main"
aws --profile fluro iam get-credential-report | jq -r .Content | base64 -d > credential-reports/credentials_fluro.csv
echo "getting and parsing credential-report: sap-main"
aws --profile giving iam get-credential-report | jq -r .Content | base64 -d > credential-reports/credentials_giving.csv
echo "getting and parsing credential-report: sap-main"
aws --profile infra iam get-credential-report | jq -r .Content | base64 -d > credential-reports/credentials_infra.csv
echo "getting and parsing credential-report: sap-main"
aws --profile nonprod iam get-credential-report | jq -r .Content | base64 -d > credential-reports/credentials_sap-nonprod.csv
# aws --profile sap iam get-credential-report | jq -r .Content | base64 -d > credential-reports/credentials_sap.csv
echo "getting and parsing credential-report: sap-main"
aws --profile snappages iam get-credential-report | jq -r .Content | base64 -d > credential-reports/credentials_snappages.csv
echo "getting and parsing credential-report: sap-main"
aws --profile stage iam get-credential-report | jq -r .Content | base64 -d > credential-reports/credentials_sap-stage.csv
echo "getting and parsing credential-report: sap-main"
aws --profile stream iam get-credential-report | jq -r .Content | base64 -d > credential-reports/credentials_streamspot.csv
echo "getting and parsing credential-report: sap-main"
aws --profile stream-stage iam get-credential-report | jq -r .Content | base64 -d > credential-reports/credentials_streamspot-stage.csv
echo "getting and parsing credential-report: sap-main"
aws --profile twomites iam get-credential-report | jq -r .Content | base64 -d > credential-reports/credentials_twomites.csv

echo "Done. Here are the downloaded CSV files:"
ls -hl credential-reports/credentials_*.csv

echo "Consolidating reports into: ./credential-report-consolidated.csv"
cat credential-reports/credentials_*.csv >> credential-report-consolidated.csv
