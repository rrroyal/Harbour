#!/bin/sh
set -e

# Enable Build Plugins
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES

