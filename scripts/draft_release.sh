#!/usr/bin/env bash
set -euo pipefail

PREVIOUS_WORKDIR="$(pwd)"

cd "$(dirname "${BASH_SOURCE[0]}")/.."
REPO_ROOT="$(pwd)"
REPO_NAME="$(gh repo view --json nameWithOwner -t '{{ .nameWithOwner }}')"
cd "$PREVIOUS_WORKDIR"

REPO_URL="https://github.com/${REPO_NAME}"
PBXPROJ="$REPO_ROOT/Harbour.xcodeproj/project.pbxproj"

# Resolve version and build number from .pbxproj
VERSION=$(grep -m1 'MARKETING_VERSION' "$PBXPROJ" | sed 's/.*= //;s/;//;s/ //')
BUILD=$(grep -m1 'CURRENT_PROJECT_VERSION' "$PBXPROJ" | sed 's/.*= //;s/;//;s/ //')
TAG="v${VERSION}"

echo "Version:	$VERSION"
echo "Build:	$BUILD"
echo "Tag:		$TAG"

# Resolve previous tag
PREVIOUS_TAG=$(git -C "$REPO_ROOT" tag --sort=-version:refname | grep -v "^${TAG}$" | head -1)
if [[ -z "$PREVIOUS_TAG" ]]; then
	echo "Error: could not determine previous tag" >&2
	exit 1
fi
echo "Previous tag: $PREVIOUS_TAG"

# Locate artifacts (expected in the current working directory)
IPA="Harbour-${TAG}-${BUILD}.ipa"
PKG="Harbour-${TAG}-${BUILD}.pkg"

for f in "$IPA" "$PKG"; do
	if [[ ! -f "$f" ]]; then
		echo "Error: artifact not found: $f" >&2
		exit 1
	fi
done

# Build release notes footer
CHANGELOG_URL="${REPO_URL}/compare/${PREVIOUS_TAG}...${TAG}"
NOTES_FILE="$(mktemp)"
trap 'rm -f "$NOTES_FILE"' EXIT
cat > "$NOTES_FILE" <<EOF

---

**Full Changelog**: ${CHANGELOG_URL}
EOF

echo "Creating tag $TAG and drafting release..."

gh release create "$TAG" \
	--repo "$REPO_NAME" \
	--title "$TAG" \
	--notes-file "$NOTES_FILE" \
	--draft \
	"$IPA" \
	"$PKG"

echo "Done. Draft release $TAG created."
