#!/bin/bash
#
# Calculates SHA1 and MD5 checksums for all artifacts
#

function calc() {
  local file=$1
  echo $1
  sha1sum $file | cut -d" " -f1 > "$file".sha1
  md5sum $file | cut -d" " -f1 > "$file".md5
}

export -f calc

find ./com -type f -not -name '*.sha1' -not -name '*.md5' -exec bash -c 'calc "{}"' \;