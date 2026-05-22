#!/usr/bin/env bash
set -e

OUT="master.m3u"
TMP="$(mktemp)"

echo "#EXTM3U" > "$OUT"

while read -r src; do
  [ -z "$src" ] && continue

  if [[ "$src" == local:* ]]; then
    file="${src#local:}"
    tail -n +2 "$file" >> "$TMP"
  else
    curl -L --silent "$src" | tail -n +2 >> "$TMP"
  fi

  echo "" >> "$TMP"
done < sources.txt

awk '
  /^#EXTINF/ { info=$0; next }
  /^https?:/ {
    if (!seen[$0]++) {
      print info
      print $0
      print ""
    }
  }
' "$TMP" >> "$OUT"

rm "$TMP"
echo "Built $OUT"