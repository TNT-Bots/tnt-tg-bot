#!/usr/bin/env bash

set -e
source "$(dirname "$0")/_conf.sh"

curl -v -k -X POST \
  -H "Content-Type: application/json" \
  -H "Cache-Control: no-cache"  \
  -d '{
  "update_id":10000,
  "message":{
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
    "text":"/start",
    "reply_to_message":{
        "date":1441645000,
        "chat":{
            "last_name":"Reply Lastname",
            "type": "private",
            "id":1111112,
            "first_name":"Reply Firstname",
            "username":"Testusername"
        },
        "message_id":1334,
        "text":"Original"
    }
  }
}' "${WEBHOOK_URL}"
