#!/bin/sh

# remove a maybe earlier build custom runtime archives
rm runtime-x86.zip
rm runtime-arm.zip

###############
## X86 BUILD ##
###############
docker build --platform=linux/amd64 --progress=plain -t lambda-custom-runtime-lambda-ric-x86 .
# extract the runtime.zip from the Docker container and store it locally
docker run --rm --entrypoint cat lambda-custom-runtime-lambda-ric-x86 runtime.zip > runtime-x86.zip

###############
## ARM BUILD ##
###############
docker build --platform=linux/arm64/v8 --progress=plain -t lambda-custom-runtime-lambda-ric-arm .
# extract the runtime.zip from the Docker container and store it locally
docker run --rm --entrypoint cat lambda-custom-runtime-lambda-ric-arm runtime.zip > runtime-arm.zip
