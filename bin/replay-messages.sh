#!/bin/bash
NAMESPACE=hmpps-pin-phone-monitor-prod
MAIN_QUEUE_SECRET_NAME=hmpps-pin-phone-monitor-sqs-output
DLQ_QUEUE_SECRET_NAME=hmpps-pin-phone-monitor-sqs-dl-output

CURRENT_TIME=$(date "+%Y.%m.%d-%H.%M.%S")

# configure awscli for the DLQ
DLQ_SECRETS=$(kubectl --namespace $NAMESPACE get secrets $DLQ_QUEUE_SECRET_NAME -o json | jq '.data | map_values(@base64d)')
DLQ_QUEUE_URL=$(echo $DLQ_SECRETS | jq --raw-output '.sqs_url' )
DLQ_ACCESS_KEY_ID=$(echo $DLQ_SECRETS | jq --raw-output '.access_key_id' )
DLQ_SECRET_ACCESS_KEY=$(echo $DLQ_SECRETS | jq --raw-output '.secret_access_key' )

export AWS_ACCESS_KEY_ID=$DLQ_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$DLQ_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=eu-west-2
export AWS_DEFAULT_OUTPUT=json

# Check if there are any messages to read on the DLQ
DLQ_QUEUE_ATTRIBUTES=$(aws sqs get-queue-attributes --queue-url $DLQ_QUEUE_URL --attribute-names All | jq '.Attributes')
DLQ_MESSAGES_VISIBLE=$(echo $DLQ_QUEUE_ATTRIBUTES | jq --raw-output '.ApproximateNumberOfMessages')
DLQ_MESSAGES_NOT_VISIBLE=$(echo $DLQ_QUEUE_ATTRIBUTES | jq --raw-output '.ApproximateNumberOfMessagesNotVisible')
DLQ_MESSAGES=$(($DLQ_MESSAGES_VISIBLE + $DLQ_MESSAGES_NOT_VISIBLE))

if [[ $DLQ_MESSAGES == 0 ]]; then 
    echo "No messages on the DLQ, exiting the script"
    exit 1
fi

if [[ $DLQ_MESSAGES_VISIBLE == 0 ]]; then 
    echo "No visible messages on the queue. Wait the cooldown peroid and re-run the script."
    echo "There are [ $DLQ_MESSAGES_NOT_VISIBLE ] currently in flight."
    exit 1
fi

echo "messages on DLQ: $DLQ_MESSAGES"
MESSAGES_FILE_NAME="~/dlq-messages".CURRENT_TIME.".json"
aws sqs receive-message --queue-url $DLQ_QUEUE_URL --max-number-of-messages 10 --attribute-names All > "$MESSAGES_FILE_NAME"




