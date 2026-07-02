//
//  CreateStackCreatorView+ViewModifiers.swift
//  Harbour
//
//  Created by royal on 15/06/2026.
//  Copyright © 2026 shameful. All rights reserved.
//

import SwiftUI

extension CreateStackCreatorView {
	struct StyledSheetViewModifier: ViewModifier {
		let presentationDetents: Set<PresentationDetent>

		init(
			presentationDetents: Set<PresentationDetent> = [.medium, .large]
		) {
			self.presentationDetents = presentationDetents
		}

		func body(content: Content) -> some View {
			content
				.presentationDetents(presentationDetents)
				.presentationSizing(.fitted)
				.presentationDragIndicator(.hidden)
//				.presentationContentInteraction(.scrolls)
		}
	}
}

extension CreateStackCreatorView {
	struct TextFieldViewModifier: ViewModifier {
		func body(content: Content) -> some View {
			content
				.autocorrectionDisabled()
				.textInputAutocapitalization(.never)
				.fontDesign(.monospaced)
				.labelsHidden()
		}
	}
}

extension CreateStackCreatorView {
	struct RequiredValueViewModifier: ViewModifier {
		let hasValue: Bool

		func body(content: Content) -> some View {
			content
				.overlay(alignment: .trailing) {
					ZStack {
						if !hasValue {
							Text(verbatim: "*")
								.font(.title3)
								.fontWeight(.semibold)
								.fontDesign(.monospaced)
								.foregroundStyle(.tertiary)
//								.transition(.opacity)
						}
					}
//					.opacity(hasValue ? 0 : 1)
					.allowsHitTesting(false)
//					.animation(.default, value: hasValue)
				}
		}
	}
}
