# Sourced by run-checks.sh: make mcp/node_modules match mcp/package-lock.json,
# offline, from the image's npm cache. A marker records the lockfile and Node it
# was installed for; it is written only after an install that succeeded.
lock_id="$(sha256sum mcp/package-lock.json | cut -d' ' -f1) $(node --version)"
marker=mcp/node_modules/.aidev-npm-lock
if [ "$(cat "$marker" 2>/dev/null)" != "$lock_id" ]; then
    echo "mcp/node_modules is not current for mcp/package-lock.json: npm ci --offline" >&2
    (cd mcp && npm ci --offline --ignore-scripts < /dev/null) || return 1
    printf '%s\n' "$lock_id" > "$marker.tmp" && mv "$marker.tmp" "$marker"
fi
