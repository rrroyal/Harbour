//
//  WithSearchBarModifier.swift
//  Harbour
//
//  Created by royal on 25/12/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonHaptics
import SwiftUI

struct WithSearchBarModifier<LeadingIconContent: View>: ViewModifier {
	@Environment(\.horizontalSizeClass) private var horizontalSizeClass
	@Binding var searchText: String
	@Binding var isSearchBarVisible: Bool
	@FocusState var isSearchFocused: Bool
	var occurenceCount: Int?
	var leadingIcon: () -> LeadingIconContent
	var doneAction: () -> Void

	private let outsidePaddingVertical: Double = 8
	private let outsidePaddingHorizontal: Double = 8

	init(
		searchText: Binding<String>,
		isSearchBarVisible: Binding<Bool>,
		isSearchFocused: FocusState<Bool>,
		occurenceCount: Int? = nil,
		@ViewBuilder leadingIcon: @escaping () -> LeadingIconContent = {
			Image(systemName: SFSymbol.search)
				.foregroundStyle(.tertiary)
		},
		doneAction: @escaping () -> Void
	) {
		self._searchText = searchText
		self._isSearchBarVisible = isSearchBarVisible
		self._isSearchFocused = isSearchFocused
		self.occurenceCount = occurenceCount
		self.leadingIcon = leadingIcon
		self.doneAction = doneAction
	}

	@ViewBuilder
	private var searchBar: some View {
		HStack(spacing: 0) {
			HStack {
				leadingIcon()

				TextField("ContainerLogsView.Search.SearchLogs", text: $searchText)
					.textFieldStyle(.plain)
					.autocorrectionDisabled()
					#if os(iOS)
					.textInputAutocapitalization(.never)
					#endif
					.focused($isSearchFocused)
			}
			.padding(.leading, 10)
			.animation(.default, value: searchText.isEmpty)

			Spacer()

			HStack(spacing: 0) {
				HStack(spacing: 4) {
					let buttonPaddingInside: Double = 8

					if let occurenceCount {
						Text(verbatim: "\(occurenceCount)")
							.font(.caption2)
							.foregroundStyle(.tertiary)
							.lineLimit(1)
							.frame(alignment: .trailing)
							.contentTransition(.numericText(value: Double(occurenceCount)))
							.animation(.default, value: occurenceCount)
					}

					if !searchText.isEmpty {
						Button {
							Haptics.generateIfEnabled(.selectionChanged)
							searchText = ""
						} label: {
							Image(systemName: SFSymbol.xmark)
								.symbolVariant(.circle.fill)
								.padding(buttonPaddingInside)
						}
						.buttonStyle(.decreasesOnPress)
						.foregroundStyle(.tertiary)
						.padding(-buttonPaddingInside)
						.transition(.symbolEffect)
					}
				}
				.frame(alignment: .trailing)

				Button {
					Haptics.generateIfEnabled(.soft)
					doneAction()
				} label: {
					Text("Generic.Done")
						.padding(.vertical, 10)
						.padding(.horizontal, 12)
						.background(.regularMaterial)
						.background(.secondary.opacity(0.1))
						.clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius - 2))
				}
				.buttonStyle(.decreasesOnPress)
				.font(.footnote)
				.foregroundStyle(.secondary)
				.padding(6)
				#if os(macOS)
				.keyboardShortcut(.defaultAction)
				#endif
			}
			.fontWeight(.semibold)
			.animation(.default, value: searchText.isEmpty)
			.fixedSize(horizontal: false, vertical: true)
		}
		.font(.callout)
		.fontWeight(.medium)
		.background(.regularMaterial)
		.background(.secondary.opacity(0.1))
		.clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
		.frame(maxWidth: 400)
		.shadow(color: .black.opacity(0.04), radius: 4)
		.padding(.vertical, outsidePaddingVertical)
		.padding(.horizontal, outsidePaddingHorizontal)
	}

	func body(content: Content) -> some View {
		if horizontalSizeClass == .compact {
			content
				.safeAreaInset(edge: .bottom, alignment: .center) {
					if isSearchBarVisible {
						searchBar
							.padding(.top, -outsidePaddingVertical)
							.transition(.move(edge: .bottom).combined(with: .blurReplace))
					}
				}
		} else {
			content
				.overlay(alignment: .topTrailing) {
					if isSearchBarVisible {
						searchBar
							.transition(.move(edge: .top).combined(with: .blurReplace))
					}
				}
		}
	}
}
