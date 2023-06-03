CONFIG = debug
PLATFORM_IOS = iOS Simulator,id=$(call udid_for,iPhone)
PLATFORM_MACOS = macOS
PLATFORM_MAC_CATALYST = macOS,variant=Mac Catalyst
PLATFORM_TVOS = tvOS Simulator,id=$(call udid_for,TV)
PLATFORM_WATCHOS = watchOS Simulator,id=$(call udid_for,Watch)

.PHONY: format test

test:
	@for platform in "$(PLATFORM_IOS)" "$(PLATFORM_MACOS)"; do \
		echo "Running tests on $${platform}"; \
		xcodebuild test \
			-configuration $(CONFIG) \
			-workspace package.xcworkspace \
			-scheme swiftui-pager \
			-destination platform="$$platform" || exit 1; \
	done;

format:
	swiftformat --config .swiftformat .

define udid_for
$(shell xcrun simctl list --json devices available $(1) | jq -r '.devices | to_entries | map(select(.value | add)) | sort_by(.key) | last.value | last.udid')
endef
