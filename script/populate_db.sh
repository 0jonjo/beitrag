#!/bin/bash

set -e

API_URL="http://localhost:3000/api/v1"
USER_COUNT=100
IP_COUNT=50
POSTS_COUNT=200000
RATINGS_PERCENTAGE=75

echo "Starting data generation at $(date)"

echo "Generating user ids at $(date)"
LOGINS=()
for ((i=1; i<=$USER_COUNT; i++)); do
  LOGINS+=("user$i")
done

echo "Generating IP addresses at $(date)"
IPS=()
for ((i=1; i<=$IP_COUNT; i++)); do
  IPS+=("192.168.1.$i")
done

echo "Creating $POSTS_COUNT posts at $(date)"
POST_IDS=()
for ((i=1; i<=$POSTS_COUNT; i++)); do

  LOGIN=${LOGINS[$RANDOM % ${#LOGINS[@]}]}
  IP=${IPS[$RANDOM % ${#IPS[@]}]}

  RESPONSE=$(curl -s -X POST "$API_URL/posts" \
    -H "Content-Type: application/json" \
    -d "{\"post\": {\"title\": \"Post $i\", \"body\": \"This is the body of post $i\", \"login\": \"$LOGIN\", \"ip\": \"$IP\"}}")

  POST_ID=$(echo $RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d ":" -f2)
  POST_IDS+=($POST_ID)

  if [ $((i % 1000)) -eq 0 ]; then
    echo "Created $i posts at $(date)"
  fi
done

echo "All posts created successfully at $(date)"

RATINGS_COUNT=$((POSTS_COUNT * RATINGS_PERCENTAGE / 100))
echo "Creating approximately $RATINGS_COUNT ratings at $(date)"

for ((i=1; i<=$RATINGS_COUNT; i++)); do
  POST_ID=${POST_IDS[$RANDOM % ${#POST_IDS[@]}]}
  USER_ID=$((($RANDOM % $USER_COUNT) + 1))
  RATING_VALUE=$((($RANDOM % 5) + 1))

  curl -s -X POST "$API_URL/ratings" \
    -H "Content-Type: application/json" \
    -d "{\"rating\": {\"post_id\": $POST_ID, \"user_id\": $USER_ID, \"value\": $RATING_VALUE}}" \
    > /dev/null

  if [ $((i % 1000)) -eq 0 ]; then
    echo "Created $i ratings at $(date)"
  fi
done

echo "Data generation completed at $(date)"
echo "Generated:"
echo "- $USER_COUNT users"
echo "- $POSTS_COUNT posts"
echo "- Using $IP_COUNT unique IP addresses"
echo "- Approximately $RATINGS_COUNT ratings"