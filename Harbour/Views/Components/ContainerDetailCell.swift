//
//  ContainerDetailCell.swift
//  Harbour
//
//  Created by royal on 05/04/2020.
//  Copyright © 2020 shameful. All rights reserved.
//

import SwiftUI

/// Cells displayed in ContainerDetailView
struct ContainerDetailCell: View {
	let label: String
	
	var body: some View {
		HStack {
			Text(label)
				.fontWeight(.medium)
				.lineLimit(1)
				.allowsTightening(true)
			Spacer()
			Image(systemName: "chevron.right")
				.font(.system(size: 15, weight: .semibold, design: .default))
				.opacity(0.2)
		}
		.padding()
		.background(RoundedRectangle(cornerRadius: 12).fill(Color.cellBackground))
		.id("containerDetailCell:\(label)")
	}
}

/* struct ContainerDetailCell_Previews: PreviewProvider {
    static var previews: some View {
        ContainerDetailCell()
    }
} */
