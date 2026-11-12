#!/usr/bin/env bash
# Generates every QR code used by the CV, locally. No third-party service:
# the images are committed once and referenced by relative path, so the README
# renders offline and keeps working if qrserver.com ever rate-limits or dies.
#
#   ./scripts/make-qr.sh
#
# Needs only node (npx). Re-run after changing a URL below.
set -euo pipefail

cd "$(dirname "$0")/.."
mkdir -p assets/qr assets/qr/png

# name <whitespace> url — a tab or spaces both work, so an editor that expands
# tabs (one did) cannot break the script.
targets=$(cat <<'EOF'
brewlite https://github.com/dungtq2k5/brewlite
wayfare https://github.com/dungtq2k5/wayfare
synapse-desk https://github.com/dungtq2k5/synapse-desk/tree/main-java
synapse-desk-demo https://synapsedeskapp.com
smartdoc-ai https://github.com/dungtq2k5/smartdoc-ai
smartwatch-e-commerce https://github.com/dungtq2k5/smartwatch-e-commerce
smartwatch-e-commerce-video-demo https://www.youtube.com/watch?v=JBbHuay3EgM
web2 https://github.com/dungtq2k5/web2-project
web2-demo https://smartwatch-store-demo.liveblog365.com/web2-project/frontend/buyer/index.php
web1 https://github.com/dungtq2k5/web1-project
web1-demo https://dungtq2k5.github.io/web1-project/
EOF
)

# Default IFS splits on any run of whitespace, so both separators parse.
while read -r name url; do
  if [ -z "${name:-}" ]; then
    continue
  fi
  if [ -z "${url:-}" ]; then
    echo "make-qr.sh: target '${name}' has no URL (one name and one URL per line)" >&2
    exit 1
  fi
  # SVG for the README; PNG at 600px for pasting into the PDF/Google Docs.
  # </dev/null: npx would otherwise swallow the remaining lines of the loop's stdin.
  npx --yes qrcode@1.5.4 -q 2 -d '#111111' -o "assets/qr/${name}.svg" "$url" </dev/null
  npx --yes qrcode@1.5.4 -q 2 -w 600 -d '#111111' -o "assets/qr/png/${name}.png" "$url" </dev/null
  printf '  %-34s %s\n' "$name" "$url"
done <<< "$targets"

echo "done."
