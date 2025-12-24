#!/usr/bin/env bash

set -e
source "$(dirname "$0")/_conf.sh"

curl --tlsv1.2 -v -k -X POST \
  -H "Content-Type: application/json" \
  -H "Cache-Control: no-cache" \
  -d '{
  "update_id":10000,
  "message":{
    "date":1441645532,
    "chat":{
       "last_name":"Test Lastname",
       "id":1111111,
       "first_name":"Test",
       "username":"Test"
    },
    "message_id":1365,
    "from":{
       "last_name":"Test Lastname",
       "id":1111111,
       "first_name":"Test",
       "username":"Test"
    },
    "text":"/start"
  }
}' "${WEBHOOK_URL}"
