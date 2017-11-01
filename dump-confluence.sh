#!/bin/bash
set -e

# Originally by aah, edited by yid

if [ $# -ne 3 ]; then
  echo "$0 spaceKey hostname username_file"
  exit 1
fi

spaceKey="$1"
hostname="$2"
username="$(<$3)"

# https://developer.atlassian.com/cloud/confluence/rest/#api-content-get
url="https://$hostname/rest/api/content"

start=0
limit=500

expand="space,body.view,version,container"

echo "Dumping $spaceKey.json..."
curl -s -u "$username" -X GET \
  "$url?spaceKey=$spaceKey&start=$start&limit=$limit" \
  >"$spaceKey.json"

mkdir -p "$spaceKey"

# get all pages in the space
jq '.results[]?.id' "$spaceKey.json" | \
  while read p; do
    echo "Dumping $spaceKey/${p//\"}.json..."
    curl -s -u "$username" -X GET "$url/${p//\"}?expand=$expand" \
      >"$spaceKey/${p//\"}.json"
  done
