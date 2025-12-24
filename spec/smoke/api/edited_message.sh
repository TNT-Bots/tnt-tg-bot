#!/usr/bin/env bash

set -e
source "$(dirname "$0")/_conf.sh"

curl -v -k -X POST \
  -H "Content-Type: application/json" \
  -H "Cache-Control: no-cache"  \
  -d '{
  "update_id":10000,
  "edited_message":{
    "date":1441645532,
    "chat":{
       "last_name":"Test Lastname",
       "type": "private",
       "id":1111111,
       "first_name":"Test Firstname",
       "username":"Testusername"
    },
    "message_id":1365,
    "from":{
       "last_name":"Test Lastname",
       "id":1111111,
       "first_name":"Test Firstname",
       "username":"Testusername"
    },
    "text":"Edited text",
    "edit_date": 1441646600
  }
}' "${WEBHOOK_URL}"
