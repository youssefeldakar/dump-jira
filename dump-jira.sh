#!/bin/bash
set -e

# Originally by aah, edited by yid

if [ $# -ne 3 ]; then
  echo "$0 query hostname username_file"
  exit 1
fi

# 'query' may be: 'project=WB', 'category=HPC'

query="$1"
hostname="$2"
username="$(<$3)"

# https://docs.atlassian.com/jira/REST/cloud/
url="https://$hostname/rest/api/latest/search"

startAt=0
maxResults=-1

expand="operations,editmeta,changelog,transitions,renderedFields"

echo "Dumping $query.json..."
curl -s -u "$username" -X GET \
  "$url?jql=$query&startAt=$startAt&maxResults=$maxResults" \
  >"$query.json"

mkdir -p "$query"

# get all issues returned by the query
jq '.issues[]?.key' "$query.json" | \
  while read k; do
    echo "Dumping $query/${k//\"}.json..."
    curl -s -u "$username" -X GET \
      "$url?jql=issue=${k//\"}&startAt=$startAt&maxResults=$maxResults&expand=$expand" \
      >"$query/${k//\"}.json"
  done
