//
//  ContainerDetailsView.swift
//  Harbour
//
//  Created by royal on 29/09/2022.
//

import SwiftUI

struct ContainerDetailsView: View {
	let item: ContainersView.ContainerNavigationItem

	var body: some View {
		Text(item.id)
			.navigationTitle(item.displayName ?? item.id)
	}
}

struct ContainerDetailsView_Previews: PreviewProvider {
	static let item = ContainersView.ContainerNavigationItem(id: "id", displayName: "DisplayName")
	static var previews: some View {
		ContainerDetailsView(item: item)
	}
}
