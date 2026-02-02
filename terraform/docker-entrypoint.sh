#!/bin/sh
set -e
echo "Running LocalStack ready hook..."

awslocal s3 mb s3://test-bucket-1

awslocal sqs create-queue \
  --queue-name test-queue.fifo \
  --attributes FifoQueue=true,ContentBasedDeduplication=true

awslocal sns create-topic \
  --name test-sns.fifo \
  --attributes FifoTopic=true

echo "Ready hook finished."