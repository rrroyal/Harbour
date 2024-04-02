//
//  StackDetailsView.swift
//  Harbour
//
//  Created by royal on 03/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import PortainerKit
import SwiftUI

// MARK: - StackDetailsView

struct StackDetailsView: View {
	@State private var viewModel: ViewModel

	init(navigationItem: NavigationItem) {
		self.viewModel = .init(navigationItem: navigationItem)
	}

	var body: some View {
		Text(viewModel.navigationItem.stackID.description)
	}
}

// MARK: - Previews

#Preview {
	StackDetailsView(navigationItem: .init(stackID: Stack.preview.id))
}
