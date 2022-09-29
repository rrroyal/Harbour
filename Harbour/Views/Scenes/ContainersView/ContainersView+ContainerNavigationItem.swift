//
//  ContainersView+ContainerNavigationItem.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//

import Foundation

extension ContainersView {
	struct ContainerNavigationItem: Hashable, Identifiable {
		let id: String
		let displayName: String?
	}
}
