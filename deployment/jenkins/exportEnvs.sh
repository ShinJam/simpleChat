#!/bin/sh

set -e

PARAMETERS=`
aws ssm get-parameters-by-path \
    --path "/kuve/staging/backend" \
    --with-decryption \
    --region ap-northeast-2 \
    --recursive
`

for row in $(echo ${PARAMETERS} | jq -c '.Parameters' | jq -c '.[]'); do
        KEY=$(basename $( echo ${row} | jq -c '.Name' | tr -d '"'))
        VALUE=$(echo ${row} | jq -c '.Value' | tr -d '"')
        export ${KEY}=${VALUE}
done
