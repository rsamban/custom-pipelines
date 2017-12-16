#!/bin/bash

sed -e "s/{{/'{{/g" -e "s/}}/}}'/g" ../../pivotal/git/pcf-pipelines/install-pcf/azure/pipeline.yml > pipeline-temp-1.yml
bosh-cli interpolate pipeline-temp-1.yml -o patches/creds-patch.yml > pipeline-temp-2.yml
bosh-cli interpolate pipeline-temp-2.yml -o patches/create-infrastructure-patch.yml > pipeline-temp-1.yml
sed -e "s/'{{/{{/g" -e "s/}}'/}}/g" pipeline-temp-1.yml > pipeline-temp-final.yml
fly format-pipeline -c pipeline-temp-final.yml > pipeline-final.yml

rm pipeline-temp-1.yml
rm pipeline-temp-2.yml
rm pipeline-temp-final.yml
