#!/usr/bin/env bash
set -e

OUT="playlists/master.m3u"
TMP="$(mktemp)"

mkdir -p playlists
echo "#EXTM3U" > "$OUT"

while IFS='|' read -r country src; do
  [[ -z "$country" || "$country" =~ ^# ]] && continue
  [[ -z "$src" ]] && continue

  if [[ "$src" == local:* ]]; then
    file="${src#local:}"
    tail -n +2 "$file" >> "$TMP"
  else
    curl -L --silent "$src" | tail -n +2 >> "$TMP"
  fi

  sed -i "s/group-title=\"[^\"]*\"/group-title=\"$country\"/g" "$TMP"
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