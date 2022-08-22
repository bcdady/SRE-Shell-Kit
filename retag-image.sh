#!/usr/bin/env sh
#
IMAGE="${1}"
COMMIT="${2}"
ENV_TAG="${3:-prod}"

ACCOUNT="576546042567"
REGION="us-west-2"
ECR_URL=${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com

# printf "ECR_URL: %s" $ECR_URL

# check parameter argument for expected value
if [ "X$IMAGE" = "X" ]; then
  echo "ERROR! Unexpected ECR image/repository specified: '$IMAGE'"
  # echo "Please specify an image name, such as go/builder, for example"

  echo "usage: retag-image.sh {image} {commit} {tag}"
  echo "example: retag-image.sh data/analytics 6be9acf6 infra"
  exit 20
fi

# check parameter argument for expected value
if [ "X$COMMIT" = "X" ]; then
  echo "ERROR! No commit id recognized."
  echo "Please provide a valid 8 character Commit ID, which would have been published from a CI job."

  echo "usage: retag-image.sh {image} {commit} {tag}"
  echo "example: retag-image.sh data/analytics 6be9acf6 infra"
  exit 31
fi

# check parameter argument for expected value
if [ "$ENV_TAG" = "dev" ] || [ "$ENV_TAG" = "infra" ] || [ "$ENV_TAG" = "stage" ] || [ "$ENV_TAG" = "prod" ]; then
  echo "Ready to retag $IMAGE:$COMMIT with environment tag $ENV_TAG"
else
  echo "Warning! Unexpected tag specified: '$ENV_TAG'"
  echo "Proceeding to retag $IMAGE:$COMMIT as $ENV_TAG"
fi

# Login to ECR; presumes you have local AWS API credentials setup. This likely need to be modified to work well with aws-vault or similar
aws ecr get-login-password | docker login ${ECR_URL} --username AWS --password-stdin

MANIFEST=$(aws ecr batch-get-image --region $REGION --repository-name $IMAGE --image-ids imageTag=$COMMIT --query 'images[].imageManifest' --output text)

if [ "X$MANIFEST" = "X" ]; then
  echo "Error: IMAGE:TAG -NOT- found in ECR : $IMAGE:$COMMIT"
else
  echo "OK: ECR IMAGE:TAG matched : $IMAGE:$COMMIT"
  aws ecr put-image --region $REGION --repository-name $IMAGE --image-tag $ENV_TAG --image-manifest "$MANIFEST" # || :
fi
