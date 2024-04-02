//
//  StackDetailsView+ViewModel.swift
//  Harbour
//
//  Created by royal on 03/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import Foundation

extension StackDetailsView {
	@Observable
	final class ViewModel {
		var navigationItem: StackDetailsView.NavigationItem

		init(navigationItem: StackDetailsView.NavigationItem) {
			self.navigationItem = navigationItem
		}
	}
}
