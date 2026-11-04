#!/usr/bin/env bash
# Usage: scripts/deploy.sh <target-org-alias>
set -euo pipefail

ORG="${1:?Usage: scripts/deploy.sh <target-org-alias>}"
OLD_ORG_ID="00Dg700000LfM8X"
OLD_USER="pankajjangir@shopee.com"

INFO=$(sf org display --target-org "$ORG" --json)
NEW_ORG_ID=$(echo "$INFO" | python3 -c 'import sys,json; print(json.load(sys.stdin)["result"]["id"][:15])')
NEW_USER=$(echo "$INFO" | python3 -c 'import sys,json; print(json.load(sys.stdin)["result"]["username"])')
echo "Target org: $NEW_ORG_ID | run-as user: $NEW_USER"

# work on a temp copy so the repo files stay untouched
BUILD=$(mktemp -d)
cp -r sfdx-project.json force-app "$BUILD"/

# published-agent output is rebuilt on publish, so deploy only the authoring bundles
rm -rf "$BUILD/force-app/main/default/aiAgents" "$BUILD/force-app/main/default/aiAgentDefinitionVersions"

# drafts only: drop the link to the old org's published agent version
find "$BUILD/force-app" -name "*.bundle-meta.xml" -exec sed -i "/<target>/d" {} +

# the fresh org generates its own consumer key
find "$BUILD/force-app" -name "*.ecaGlblOauth-meta.xml" -exec sed -i "/<consumerKey>/d" {} +

# the fresh org creates its own OAuth link
find "$BUILD/force-app" -name "*.ecaOauth-meta.xml" -exec sed -i "/<oauthLink>/d" {} +

# swap the three org-specific values
grep -rl -e "$OLD_ORG_ID" -e "$OLD_USER" "$BUILD/force-app" | xargs -r sed -i "s/$OLD_ORG_ID/$NEW_ORG_ID/g; s/$OLD_USER/$NEW_USER/g"

( cd "$BUILD" && sf project deploy start --source-dir force-app --target-org "$ORG" )
rm -rf "$BUILD"
