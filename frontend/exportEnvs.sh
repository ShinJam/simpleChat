#!/bin/sh

set -e

PARAMETERS=`
aws ssm get-parameters-by-path \
    --path "/kuve_eks/staging/frontend" \
    --with-decryption \
    --region ap-northeast-2 \
    --recursive
`

[ -e .env ] && rm .env
for row in $(echo ${PARAMETERS} | jq -c '.Parameters' | jq -c '.[]'); do
        KEY=$(basename $( jq -c '.Name' <<< ${row} | tr -d '"'))
        VALUE=$(jq -c '.Value' <<< ${row} | tr -d '"')
        echo ${KEY}=${VALUE} >> .env
done
