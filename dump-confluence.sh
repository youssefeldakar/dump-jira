#!/bin/bash
set -e

# Copyright (C) 2018 Bibliotheca Alexandrina <www.bibalex.org>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
