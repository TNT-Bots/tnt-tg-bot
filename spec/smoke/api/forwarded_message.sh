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
       "id":1111111,
       "type": "private",
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
    "forward_from": {
       "last_name":"Forward Lastname",
       "id": 222222,
       "first_name":"Forward Firstname"
    },
    "forward_date":1441645550,
    "text":"/start"
  }
}' "${WEBHOOK_URL}"
