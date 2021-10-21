//
//  EnvironmentValues+.swift
//  Harbour
//
//  Created by royal on 21/10/2021.
//

import SwiftUI

extension EnvironmentValues {
	private struct UseContainerGridView: EnvironmentKey {
		static let defaultValue: Bool = false
	}
	
	var useContainerGridView: Bool {
		get { self[UseContainerGridView.self] }
		set { self[UseContainerGridView.self] = newValue }
	}
	
	private struct UseColoredContainerCells: EnvironmentKey {
		static let defaultValue: Bool = false
	}
	
	var useColoredContainerCells: Bool {
		get { self[UseColoredContainerCells.self] }
		set { self[UseColoredContainerCells.self] = newValue }
	}
}
