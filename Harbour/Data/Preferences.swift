//
//  Preferences.swift
//  Harbour
//
//  Created by royal on 11/06/2021.
//

import Foundation
import SwiftUI

class Preferences: ObservableObject {
	public static let shared: Preferences = Preferences()
	
	public let ud: UserDefaults = UserDefaults.standard
	
	private init() { }
}
