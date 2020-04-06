//
//  DeviceInfo.swift
//  Harbour
//
//  Created by royal on 05/04/2020.
//  Copyright © 2020 shameful. All rights reserved.
//

import UIKit

struct DeviceInfo {
	struct Orientation {
		static var interfaceOrientation: UIInterfaceOrientation {
			get {
				#if os(macOS)
				return UIInterfaceOrientation.landscapeRight
				#endif
				
				return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? UIInterfaceOrientation.unknown
			}
		}
		
		static var isLandscape: Bool {
			get {
				#if os(macOS)
				return true
				#endif
				
				return UIDevice.current.orientation.isValidInterfaceOrientation
					? UIDevice.current.orientation.isLandscape
					: DeviceInfo.Orientation.interfaceOrientation == .landscapeRight || DeviceInfo.Orientation.interfaceOrientation == .landscapeLeft
			}
		}
    
		static var isPortrait: Bool {
			get {
				#if os(macOS)
				return false
				#endif
				
				return UIDevice.current.orientation.isValidInterfaceOrientation
					? UIDevice.current.orientation.isPortrait
					: DeviceInfo.Orientation.interfaceOrientation == .portrait || DeviceInfo.Orientation.interfaceOrientation == .portraitUpsideDown
			}
		}
	}
}
