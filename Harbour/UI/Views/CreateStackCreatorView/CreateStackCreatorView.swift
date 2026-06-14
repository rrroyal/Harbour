//
//  CreateStackCreatorView.swift
//  Harbour
//
//  Created by royal on 14/06/2026.
//  Copyright © 2026 shameful. All rights reserved.
//

import CommonHaptics
import PortainerKit
import SwiftUI

// MARK: - CreateStackCreatorView

struct CreateStackCreatorView: View {
	@Environment(SceneDelegate.self) private var sceneDelegate
	@Environment(\.dismiss) private var dismiss
	@Environment(\.errorHandler) private var errorHandler
	@Environment(\.presentIndicator) private var presentIndicator
	@State private var viewModel: ViewModel

	var onStackCreation: ((Stack) -> Void)?

	init(portainerStore: PortainerStore, onStackCreation: ((Stack) -> Void)? = nil) {
		self._viewModel = .init(initialValue: ViewModel(portainerStore: portainerStore))
		self.onStackCreation = onStackCreation
	}

	var body: some View {
		Form {
			NameSection()
			ServicesSection()
			NetworksSection()
		}
		.formStyle(.grouped)
		.scrollDismissesKeyboard(.interactively)
		#if os(iOS)
		.safeAreaInset(edge: .bottom) {
			CreateButton(submitAction: submitStack)
				.buttonStyle(.customPrimary(backgroundColor: viewModel.createStackError != nil ? .red : .accentColor))
				.padding()
				.background(Color.groupedBackground)
		}
		#endif
		.sheet(item: $viewModel.serviceSheetMode) { mode in
			ServiceEditorView(service: mode.unwrapped)
		}
		.sheet(item: $viewModel.networkSheetMode) { mode in
			NetworkEditorView(network: mode.unwrapped)
				.presentationDetents([.medium, .large])
				.presentationDragIndicator(.hidden)
				.presentationContentInteraction(.resizes)
		}
		.toolbar {
			#if os(macOS)
			ToolbarItem(placement: .primaryAction) {
				CreateButton(submitAction: submitStack)
			}
			#endif
		}
		.environment(viewModel)
		.navigationTitle("CreateStackView.Title.Create")
		.animation(.default, value: viewModel.isLoading)
		.animation(.default, value: viewModel.createStackError != nil)
	}
}

// MARK: - CreateStackCreatorView+CreateButton

extension CreateStackCreatorView {
	struct CreateButton: View {
		@Environment(CreateStackCreatorView.ViewModel.self) private var viewModel

		let submitAction: () -> Void

		var body: some View {
			Button {
				submitAction()
			} label: {
				if viewModel.isLoading {
					ProgressView()
						#if os(macOS)
						.controlSize(.small)
						#endif
				} else if let error = viewModel.createStackError {
					Text(error.localizedDescription)
				} else {
					Label("CreateStackView.Create", systemImage: "plus")
				}
			}
			.keyboardShortcut(.defaultAction)
			.disabled(!viewModel.canCreateStack)
			.disabled(viewModel.isLoading)
			.animation(.default, value: viewModel.canCreateStack)
		}
	}
}

// MARK: - NameSection

private extension CreateStackCreatorView {
	struct NameSection: View {
		@Environment(CreateStackCreatorView.ViewModel.self) private var viewModel
		@FocusState private var isFocused: Bool

		var body: some View {
			@Bindable var viewModel = viewModel

			NormalizedSection {
				TextField("CreateStackView.Name", text: $viewModel.stackName)
					.fontDesign(.monospaced)
					.autocorrectionDisabled()
					.labelsHidden()
					.submitLabel(.continue)
					.focused($isFocused)
			} header: {
				Text("CreateStackView.Name")
			} footer: {
				Text("CreateStackView.Name.Footer")
			}
		}
	}
}

// MARK: - ServicesSection

private extension CreateStackCreatorView {
	struct ServicesSection: View {
		@Environment(CreateStackCreatorView.ViewModel.self) private var viewModel

		var body: some View {
			NormalizedSection {
				ForEach(viewModel.services) { service in
					Button {
						viewModel.serviceSheetMode = .edit(service)
					} label: {
						VStack(alignment: .leading) {
							Text(service.name.isReallyEmpty ? String(localized: "CreateStackView.ComposeCreator.Service.Unnamed") : service.name)
								.fontDesign(.monospaced)
								.foregroundStyle(service.name.isReallyEmpty ? .secondary : .primary)

							Text(service.image.isReallyEmpty ? String(localized: "CreateStackView.ComposeCreator.Service.NoImage") : service.image)
								.font(.caption)
								.fontDesign(.monospaced)
								.foregroundStyle(.secondary)
						}
					}
					.contextMenu {
						Button {
							viewModel.serviceSheetMode = .edit(service)
						} label: {
							Label("Generic.Edit", systemImage: SFSymbol.edit)
						}
						.labelStyle(.titleAndIcon)

						Button(role: .destructive) {
							viewModel.removeService(service)
						} label: {
							Label("Generic.Remove", systemImage: SFSymbol.remove)
						}
						.labelStyle(.titleAndIcon)
					}
					.swipeActions(edge: .trailing) {
						Button(role: .destructive) {
							viewModel.removeService(service)
						} label: {
							Label("Generic.Remove", systemImage: SFSymbol.remove)
						}
					}
				}

				Button {
					viewModel.serviceSheetMode = .create
				} label: {
					Label("Generic.Add", systemImage: SFSymbol.plus)
				}
			} header: {
				Text("CreateStackView.ComposeCreator.Services")
			} footer: {
				Text("CreateStackView.ComposeCreator.Services.Footer")
			}
			.animation(.default, value: viewModel.services)
		}
	}
}

// MARK: - NetworksSection

private extension CreateStackCreatorView {
	struct NetworksSection: View {
		@Environment(CreateStackCreatorView.ViewModel.self) private var viewModel

		var body: some View {
			NormalizedSection {
				ForEach(viewModel.networks) { network in
					Button {
						viewModel.networkSheetMode = .edit(network)
					} label: {
						HStack {
							Text(network.name)
								.fontDesign(.monospaced)
						}
					}
					.contextMenu {
						Button {
							viewModel.networkSheetMode = .edit(network)
						} label: {
							Label("Generic.Edit", systemImage: SFSymbol.edit)
						}
						.labelStyle(.titleAndIcon)

						Button(role: .destructive) {
							viewModel.removeNetwork(network)
						} label: {
							Label("Generic.Remove", systemImage: SFSymbol.remove)
						}
						.labelStyle(.titleAndIcon)
					}
					.swipeActions(edge: .trailing) {
						Button(role: .destructive) {
							viewModel.removeNetwork(network)
						} label: {
							Label("Generic.Remove", systemImage: SFSymbol.remove)
						}
					}
				}

				Button {
					viewModel.networkSheetMode = .create
				} label: {
					Label("Generic.Add", systemImage: SFSymbol.plus)
				}
			} header: {
				Text("CreateStackView.ComposeCreator.Networks")
			} footer: {
				Text("CreateStackView.ComposeCreator.Networks.Footer")
			}
			.animation(.default, value: viewModel.networks)
		}
	}
}

// MARK: - Actions

private extension CreateStackCreatorView {
	@MainActor
	func submitStack() {
		Task {
			guard viewModel.canCreateStack else { return }

			let stackName = viewModel.stackName

			do {
				Haptics.generateIfEnabled(.light)

				let stack = try await viewModel.createStack().value

				let indicatorAction: PresentedIndicator.Action = {
					let navigationItem = StackDetailsView.NavigationItem(stackID: stack.id.description, stackName: stack.name)
					Task { @MainActor in
						sceneDelegate.resetSheets()
						sceneDelegate.navigate(to: .stacks, with: navigationItem)
					}
				}
				presentIndicator(.stackCreate(stackName: stackName, state: .success, action: indicatorAction))
				Haptics.generateIfEnabled(.success)
				onStackCreation?(stack)

				dismiss()
			} catch {
				presentIndicator(.stackCreate(stackName: stackName, state: .failure(error)))
				Haptics.generateIfEnabled(.error)
				errorHandler(error, showIndicator: false)
			}
		}
	}
}

// MARK: - Previews

#Preview {
	let preferences = Preferences()
	let portainerStore = PortainerStore(preferences: preferences)
	NavigationStack {
		CreateStackCreatorView(portainerStore: portainerStore)
	}
}
