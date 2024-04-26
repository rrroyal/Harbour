//
//  AppDelegate+NSApplicationDelegate.swift
//  Harbour
//
//  Created by royal on 30/03/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

#if canImport(AppKit) && os(macOS)
import AppKit

extension AppDelegate: NSApplicationDelegate {
	func applicationDidFinishLaunching(_ notification: Notification) {
//		for window in NSApplication.shared.windows {
//			window.titleVisibility = .hidden
//			window.titlebarAppearsTransparent = true
//			window.isOpaque = false
//			window.backgroundColor = NSColor.clear
//		}
	}
}
#endif
