//
//  AppDelegate.swift
//  Harbour
//
//  Created by royal on 17/10/2021.
//

import UIKit
import PortainerKit

class AppDelegate: NSObject, UIApplicationDelegate {
	let inputPipe = Pipe()	
	let outputPipe = Pipe()
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		inputPipe.fileHandleForReading.readabilityHandler = { [weak self] fileHandle in
			let data = fileHandle.availableData
			if let string = String(data: data, encoding: .utf8) {
				_LOGS.append(string.trimmingCharacters(in: .whitespacesAndNewlines))
			}
			
			// Write input back to stdout
			self?.outputPipe.fileHandleForWriting.write(data)
		}
		
		dup2(STDOUT_FILENO, outputPipe.fileHandleForWriting.fileDescriptor)
		dup2(STDERR_FILENO, outputPipe.fileHandleForWriting.fileDescriptor)
		
		dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
		dup2(inputPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
				
		return true
	}
}
