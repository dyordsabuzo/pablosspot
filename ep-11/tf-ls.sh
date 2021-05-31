#!/bin/sh
set -e

docker run -v $PWD:/workspace \
    -v $PWD/localstack/providers.tf:/workspace/infrastructure/providers.tf \
    -w /workspace/infrastructure \
    --network localstack hashicorp/terraform $@