APP_NAME = air-push
BIN_DIR = /usr/local/bin
BUILD_DIR := $(shell swift build -c release --show-bin-path)

.PHONY: build install uninstall clean

build:
	swift build -c release --disable-sandbox

install: build
	install "$(BUILD_DIR)/$(APP_NAME)" "$(BIN_DIR)"

uninstall:
	rm "$(BIN_DIR)/$(APP_NAME)"

clean:
	swift package clean
