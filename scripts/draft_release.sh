#!/usr/bin/env bash
set -euo pipefail

# Parse command line arguments
VERSION_FLAG=""
BUILD_FLAG=""
ARGS=()

while [[ $# -gt 0 ]]; do
	case $1 in
		--version)
			VERSION_FLAG="$2"
			shift 2
			;;
		--build)
			BUILD_FLAG="$2"
			shift 2
			;;
		*)
			ARGS+=("$1")
			shift
			;;
	esac
done

# Detect or assign IPA and PKG files
IPA_INPUT=""
PKG_INPUT=""

# Process provided arguments and assign by extension
for f in "${ARGS[@]}"; do
	if [[ ! -f "$f" ]]; then
		echo "Error: artifact not found: $f" >&2
		exit 1
	fi
	if [[ "$f" == *.ipa ]]; then
		if [[ -n "$IPA_INPUT" ]]; then
			echo "Error: multiple .ipa files provided" >&2
			exit 1
		fi
		IPA_INPUT="$f"
	elif [[ "$f" == *.pkg ]]; then
		if [[ -n "$PKG_INPUT" ]]; then
			echo "Error: multiple .pkg files provided" >&2
			exit 1
		fi
		PKG_INPUT="$f"
	else
		echo "Error: file must be .ipa or .pkg: $f" >&2
		exit 1
	fi
done

# Auto-detect missing files from current directory
if [[ -z "$IPA_INPUT" ]]; then
	echo "No .ipa file provided, searching current directory..."
	IPA_FILES=(*.ipa)
	if [[ ${#IPA_FILES[@]} -eq 1 && -f "${IPA_FILES[0]}" ]]; then
		IPA_INPUT="${IPA_FILES[0]}"
		echo "Found: $IPA_INPUT"
	elif [[ ${#IPA_FILES[@]} -gt 1 ]]; then
		echo "Error: multiple .ipa files found in current directory. Please specify which one to use." >&2
		exit 1
	else
		echo "Error: no .ipa file found in current directory" >&2
		exit 1
	fi
fi

if [[ -z "$PKG_INPUT" ]]; then
	echo "No .pkg file provided, searching current directory..."
	PKG_FILES=(*.pkg)
	if [[ ${#PKG_FILES[@]} -eq 1 && -f "${PKG_FILES[0]}" ]]; then
		PKG_INPUT="${PKG_FILES[0]}"
		echo "Found: $PKG_INPUT"
	elif [[ ${#PKG_FILES[@]} -gt 1 ]]; then
		echo "Error: multiple .pkg files found in current directory. Please specify which one to use." >&2
		exit 1
	else
		echo "Error: no .pkg file found in current directory" >&2
		exit 1
	fi
fi

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

PREVIOUS_WORKDIR="$(pwd)"

cd "$(dirname "${BASH_SOURCE[0]}")/.."
REPO_ROOT="$(pwd)"
REPO_NAME="$(gh repo view --json nameWithOwner -t '{{ .nameWithOwner }}')"
cd "$PREVIOUS_WORKDIR"

REPO_URL="https://github.com/${REPO_NAME}"
PBXPROJ="$REPO_ROOT/Harbour.xcodeproj/project.pbxproj"

# Resolve version and build number
if [[ -n "$VERSION_FLAG" ]]; then
	VERSION="$VERSION_FLAG"
else
	VERSION=$(grep -m1 'MARKETING_VERSION' "$PBXPROJ" | sed 's/.*= //;s/;//;s/ //')
fi

if [[ -n "$BUILD_FLAG" ]]; then
	BUILD="$BUILD_FLAG"
else
	BUILD=$(grep -m1 'CURRENT_PROJECT_VERSION' "$PBXPROJ" | sed 's/.*= //;s/;//;s/ //')
fi

TAG="v${VERSION}"

echo "Version: $VERSION, build: $BUILD, tag: $TAG"

IPA_FILE="$TEMP_DIR/Harbour-v${VERSION}-${BUILD}.ipa"
cp "$IPA_INPUT" "$IPA_FILE"
PKG_FILE="$TEMP_DIR/Harbour-v${VERSION}-${BUILD}.pkg"
cp "$PKG_INPUT" "$PKG_FILE"

# Resolve previous tag
PREVIOUS_TAG=$(git -C "$REPO_ROOT" tag --sort=-version:refname | grep -v "^${TAG}$" | head -1)
if [[ -z "$PREVIOUS_TAG" ]]; then
	echo "Error: could not determine previous tag" >&2
	exit 1
fi

# Build release notes footer
CHANGELOG_URL="${REPO_URL}/compare/${PREVIOUS_TAG}...${TAG}"
NOTES_FILE="${TEMP_DIR}/notes.txt"
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
	"$IPA_FILE" \
	"$PKG_FILE"

echo "Done. Draft release $TAG created."
