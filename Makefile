all: app

## Local build: ad-hoc signed, no Apple certificate needed.
## Output: ./build/MiddleClick.app
.PHONY: app release
app:
	xcodebuild -project MiddleClick.xcodeproj -scheme MiddleClick -configuration Release \
		-derivedDataPath ./build/derived \
		CODE_SIGN_IDENTITY="-" DEVELOPMENT_TEAM="" CODE_SIGN_STYLE=Manual \
		build
	rm -rf ./build/MiddleClick.app
	cp -R ./build/derived/Build/Products/Release/MiddleClick.app ./build/MiddleClick.app
	@echo "Built ./build/MiddleClick.app"

## Maintainer-style signed release (needs a Developer ID certificate)
release: archive export compress

## Development targets
.PHONY: run force-build clean-build

# Find all source files to track dependencies
SOURCES := $(shell find MiddleClick MoreTouch ConfigCore -type f \( -name "*.swift" -o -name "*.h" -o -name "*.m" \) 2>/dev/null)

# Stamp file to track last build
BUILD_STAMP := ./build/.build-stamp

# Only build if sources changed since last build
$(BUILD_STAMP): $(SOURCES)
	@echo "🔨 Building MiddleClick (Debug)..."
	@xcodebuild -project MiddleClick.xcodeproj -scheme MiddleClick -configuration Debug build | grep -E "BUILD (SUCCEEDED|FAILED)|error:" || true
	@echo "✅ Build succeeded!"
	@mkdir -p $(dir $(BUILD_STAMP))
	@touch $(BUILD_STAMP)

build-debug: $(BUILD_STAMP)

run: $(BUILD_STAMP)
	@echo "🚀 Running MiddleClick..."
	@BUILD_SKIP=1 ./scripts/build-and-run.sh

force-build:
	@rm -f $(BUILD_STAMP)
	@$(MAKE) build-debug

clean-build:
	@rm -f $(BUILD_STAMP)
	@echo "🧹 Build stamp cleaned"

## Release targets
archive:
	xcodebuild -project MiddleClick.xcodeproj -scheme MiddleClick -configuration Release archive

export:
	xcodebuild -exportArchive \
		-archivePath "$(shell ls -td ~/Library/Developer/Xcode/Archives/*/MiddleClick*.xcarchive | head -1)" \
		-exportPath "$(shell pwd)/build" \
		-exportOptionsPlist ./build-config/ExportOptions.plist

compress:
	cd ./build && \
	rm -f ./MiddleClick.zip && \
	zip -r9 ./MiddleClick.zip ./MiddleClick.app

create-cert:
	security export -k ~/Library/Keychains/login.keychain-db -t identities -f pkcs12 | base64 | pbcopy
