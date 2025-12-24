#!/usr/bin/env bash

set -e
source "$(dirname "$0")/_conf.sh"

curl -v -k -X POST \
  -H "Content-Type: application/json" \
  -H "Cache-Control: no-cache"  \
  -d '{
  "update_id":10000,
  "callback_query":{
    "id": "4382bfdwdsb323b2d9",
    "from":{
       "last_name":"Test Lastname",
       "type": "private",
       "id":1111111,
       "first_name":"Test Firstname",
       "username":"Testusername"
    },
    "data": "Data from button callback",
    "inline_message_id": "1234csdbsk4839"
  }
}' "${WEBHOOK_URL}"
