#!/usr/bin/env sh

CI_PROJECT_DIR="/Users/bryandady/go/src/fluro/" # "/Users/bryandady/repo/ops/kubernetes-app-helm-chart"

GROUP="${1:-ops}"
PROJ="${2}"
CI_COMMIT_SHORT_SHA="${3}"
ENV="${4:-stage}"

CHART_VERSION="1.x" # https://subsplash.io/ops/kubernetes-app-helm-chart
# ACCOUNT="576546042567"
REGION="us-west-2"
# ECR_URL=${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com

KUBERNETES_JOB="0"
LABELS=""

# check parameter argument for expected value
if [ "X$GROUP" = "X" ]; then
  echo "ERROR! Unexpected GROUP specified: '$GROUP'"
  echo "Please specify a project Group name (namespace), such as 'go', for example"
  exit 22
fi

# check parameter argument for expected value
if [ "X$PROJ" = "X" ]; then
  echo "ERROR! Unexpected PROJ specified: '$PROJ'"
  echo "Please specify a project name, such as builder, for example"
  exit 29
fi

# check parameter argument for expected value
if [ "X$CI_COMMIT_SHORT_SHA" = "X" ]; then
  echo "ERROR! No commit id recognized."
  echo "Please provide a valid 8 character Commit ID, which would have been published from a CI job."
  exit 36
fi

# check parameter argument for expected value
if [ "$ENV" = "dev" ] || [ "$ENV" = "infra" ] || [ "$ENV" = "stage" ] || [ "$ENV" = "prod" ]; then
  echo "Ready to retag ${GROUP}/${PROJ}:$CI_COMMIT_SHORT_SHA with environment tag $ENV"
else
  echo "Warning! Unexpected tag specified: '$ENV'"
fi

# Login to ECR; presumes you have local AWS API credentials setup. This likely need to be modified to work well with aws-vault or similar
aws ecr get-login-password | docker login 576546042567.dkr.ecr.us-west-2.amazonaws.com --username AWS --password-stdin

MANIFEST=$(aws ecr batch-get-image --region $REGION --repository-name $GROUP/$PROJ \
  --image-ids imageTag=$CI_COMMIT_SHORT_SHA --query 'images[].imageManifest' --output text)
if [ "X$MANIFEST" = "X" ]; then
  echo "IMAGE:TAG not found in ECR $GROUP/$PROJ:$CI_COMMIT_SHORT_SHA"
  echo "Proceeding with deploying existing IMAGE:TAG $GROUP/$PROJ:$ENV"
else
  echo "OK: ECR IMAGE:TAG matched $GROUP/$PROJ:$CI_COMMIT_SHORT_SHA"
  aws ecr put-image --region $REGION --repository-name $GROUP/$PROJ --image-tag $ENV --image-manifest "$MANIFEST" || :
fi

# echo deploy-slack-notification
# https://subsplash.io/go/tools/deploy-slack-notification
# deploy-slack-notification -project "$PROJ" -env "$ENV" -env_url "$CI_ENVIRONMENT_URL" -ref "$CI_COMMIT_REF_NAME" -user "$GITLAB_USER_NAME" -url "$CI_JOB_URL"

# Get base helm chart template
# git clone https://subsplash.io/ops/kubernetes-app-helm-chart.git --branch ${CHART_VERSION} --single-branch || :

# Connect / authenticate with target k8s cluster and namespace
# aws eks update-kubeconfig --name sap-${ENV} --region $REGION

# Check variables / conditions and deploy helm chart(s) accordingly
if [[ $KUBERNETES_JOB == "1" ]]; then
  TYPE="job"
  CHART_TEMPLATE="daemon-base-job"
  NAMESPACE="cron-${GROUP}-${PROJ}"
else
  TYPE="deployment"
  CHART_TEMPLATE="app-base-http"
  NAMESPACE="app-${GROUP}-${PROJ}"
  if [[ $GROUP == "go" ]]; then
    NAMESPACE="app-${PROJ}"
  fi
fi

kubectl create namespace ${NAMESPACE} || true
kubectl label --overwrite=true namespace ${NAMESPACE} developer-access=allow

echo "Deploying image: ${GROUP}/${PROJ}:${ENV} as ${CHART_TEMPLATE}"
helm verify ./kubernetes-app-helm-chart/${CHART_TEMPLATE}/.
helm upgrade ${NAMESPACE} ./kubernetes-app-helm-chart/${CHART_TEMPLATE}/. --install --timeout=300s --reset-values --atomic --cleanup-on-fail \
  --namespace ${NAMESPACE} \
  -f ./kubernetes-app-helm-chart/${CHART_TEMPLATE}/values.yaml \
  -f ${CI_PROJECT_DIR}/chart/values.yaml \
  -f ${CI_PROJECT_DIR}/chart/values-${ENV}.yaml

kubectl get events -n ${NAMESPACE}
