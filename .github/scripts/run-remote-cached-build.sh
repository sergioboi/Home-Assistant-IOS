#!/usr/bin/env bash

set -euo pipefail

if [[ -z "${XCODECACHEPROG_TOKEN:-}" ]]; then
  echo "XCODECACHEPROG_TOKEN is required for remote cache builds" >&2
  exit 1
fi

CREDENTIAL_NAME="${XCODECACHEPROG_CREDENTIAL_NAME:-home-assistant-ios}"
CONFIG_DIR="${RUNNER_TEMP}/xcodecacheprog"
CONFIG_FILE="${CONFIG_DIR}/XcodeRemoteCache.xcconfig"
DERIVED_DATA_PATH="${CAS_DERIVED_DATA_PATH:-${RUNNER_TEMP}/homeassistant-cas-derived-data}"
RESULT_BUNDLE_PATH="${RUNNER_TEMP}/homeassistant-cas-result-bundles/$(date +%s)-$$.xcresult"

mkdir -p "$CONFIG_DIR"
mkdir -p "$(dirname "$RESULT_BUNDLE_PATH")"

echo "Configuring Xcode remote compilation cache"
xcodecacheprog sync \
  --credential-name "$CREDENTIAL_NAME" \
  --credential-env XCODECACHEPROG_TOKEN

echo "Writing remote cache xcconfig: ${CONFIG_FILE}"
xcodecacheprog config > "$CONFIG_FILE"

echo "Remote cache status before build"
xcodecacheprog status

echo "Running Home Assistant build"
XCODE_XCCONFIG_FILE="$CONFIG_FILE" xcodebuild build \
  -project HomeAssistant.xcodeproj \
  -scheme App-Debug \
  -destination "platform=iOS Simulator,name=iPhone 17,OS=latest" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  -resultBundlePath "$RESULT_BUNDLE_PATH" \
  CODE_SIGNING_ALLOWED=NO \
  COMPILER_INDEX_STORE_ENABLE=NO

echo
echo "Remote cache status after build"
xcodecacheprog status
