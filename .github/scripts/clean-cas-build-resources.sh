#!/usr/bin/env bash

set -euo pipefail

DERIVED_DATA_PATH="${CAS_DERIVED_DATA_PATH:-${RUNNER_TEMP}/homeassistant-cas-derived-data}"

echo "Cleaning Xcode build products"
xcodebuild clean \
  -project HomeAssistant.xcodeproj \
  -scheme App-Debug \
  -destination "platform=iOS Simulator,name=iPhone 17,OS=latest" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  CODE_SIGNING_ALLOWED=NO \
  COMPILER_INDEX_STORE_ENABLE=NO

echo "Removing CAS cache workflow DerivedData"
rm -rf "$DERIVED_DATA_PATH"

echo "Removing Xcode result bundles"
rm -rf "${RUNNER_TEMP}/homeassistant-cas-result-bundles"
