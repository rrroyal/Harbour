//
//  ErrorView.swift
//  HarbourWidgets
//
//  Created by royal on 04/10/2022.
//

import SwiftUI

// MARK: - ErrorView

struct ErrorView: View {
	let error: Error

	var body: some View {
		Text(error.localizedDescription)
			.font(.body)
			.fontDesign(.monospaced)
			.fontWeight(.medium)
			.foregroundStyle(.red)
			.multilineTextAlignment(.center)
			.lineLimit(nil)
			.minimumScaleFactor(0.7)
			.padding()
	}
}

// MARK: - Previews

struct ErrorView_Previews: PreviewProvider {
	static var previews: some View {
		ErrorView(error: GenericError.invalidURL)
	}
}
