#!/bin/bash
set -e
cd "$(dirname "$0")/../dist"
out=zel-index.json
echo '{"packages":[' >"$out"
first=1
for z in *.zel; do
  [ -e "$z" ] || continue
  meta=$(zstd -dc "$z" | tar -xOf - zel.toml 2>/dev/null)
  name=$(echo "$meta" | sed -n 's/^name = "\(.*\)"/\1/p')
  version=$(echo "$meta" | sed -n 's/^version = "\(.*\)"/\1/p')
  desc=$(echo "$meta" | sed -n 's/^description = "\(.*\)"/\1/p')
  sha=$(sha256sum "$z" | cut -d" " -f1)
  [ $first -eq 0 ] && echo "," >>"$out"
  first=0
  printf '{"name":"%s","version":"%s","description":"%s","deps":[],"file":"%s","sha256":"%s"}' "$name" "$version" "$desc" "$z" "$sha" >>"$out"
done
echo ']}' >>"$out"
echo "wrote $out"
