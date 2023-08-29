#!/bin/zsh
set -e

# Enable Build Plugins
echo "Enabling Build Plugins..."
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES

echo "Done!"
