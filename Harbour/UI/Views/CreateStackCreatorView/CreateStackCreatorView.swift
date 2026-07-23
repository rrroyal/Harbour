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

// TODO: (UI) Haptics

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
			EnvironmentSection()
			// TODO: (Docker) Volumes
			NetworksSection()
		}
		.formStyle(.grouped)
		.scrollDismissesKeyboard(.interactively)
		.sheet(item: $viewModel.serviceEditorMode) { mode in
			NavigationStack {
				ServiceView(service: mode.unwrapped)
					.addingCloseButton()
			}
			.modifier(StyledSheetViewModifier(presentationDetents: [.large]))
			.environment(viewModel)
		}
		.sheet(item: $viewModel.networkEditorMode) { mode in
			ServiceView.EditNetworkSheetContentView(
				network: mode.unwrapped,
				networks: $viewModel.networks,
				onDidSave: nil
			)
			.modifier(StyledSheetViewModifier())
		}
		.sheet(item: $viewModel.environmentEditorMode) { mode in
			ServiceView.EditEnvironmentSheetContentView(
				entry: mode.unwrapped,
				environment: $viewModel.stackEnvironment,
				suggestions: .init()
			)
			.modifier(StyledSheetViewModifier())
		}
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				CreateButton(submitAction: submitStack)
			}
		}
		.environment(viewModel)
		.navigationTitle("CreateStackView.Title.Create")
		.animation(.default, value: viewModel.isLoading)
		.animation(.default, value: viewModel.stackEnvironment)
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
				} else if let error = viewModel.createStackError {
					Text(error.localizedDescription)
				} else {
					Label(
						"Generic.Create",
						systemImage: SFSymbol.checkmark
					)
				}
			}
			.buttonStyle(.borderedProminent)
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
				TextField(
					"CreateStackView.Name",
					value: $viewModel.stackName.replacing(" ", with: "-"),
					formatter: ReplacingCharactersFormatter(replacing: " ", with: "-")
				)
				.modifier(CreateStackCreatorView.TextFieldViewModifier())
				.modifier(CreateStackCreatorView.RequiredValueViewModifier(hasValue: !viewModel.stackName.isReallyEmpty))
				.submitLabel(.done)
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
						viewModel.serviceEditorMode = .edit(service)
					} label: {
						Text(service.serviceName)
							.fontDesign(.monospaced)
							.fullWidth(alignment: .leading)
					}
//					.contextMenu {
//						Button {
//							viewModel.serviceEditorMode = .edit(service)
//						} label: {
//							Label("Generic.Edit", systemImage: SFSymbol.edit)
//						}
//						.labelStyle(.titleAndIcon)
//
//						Button(role: .destructive) {
//							viewModel.removeService(service)
//						} label: {
//							Label("Generic.Remove", systemImage: SFSymbol.remove)
//						}
//						.labelStyle(.titleAndIcon)
//					}
					.swipeActions(edge: .trailing) {
						Button(role: .destructive) {
							viewModel.removeService(service)
						} label: {
							Label("Generic.Remove", systemImage: SFSymbol.remove)
						}
					}
				}

				Button {
					viewModel.serviceEditorMode = .add
				} label: {
					Label("Generic.Add", systemImage: SFSymbol.plus)
						.fullWidth(alignment: .leading)
				}
				.modifier(CreateStackCreatorView.RequiredValueViewModifier(hasValue: !viewModel.services.isEmpty))
			} header: {
				Text("CreateStackView.ComposeCreator.Services")
			} footer: {
				Text("CreateStackView.ComposeCreator.Services.Footer")
			}
			.animation(.default, value: viewModel.services)
		}
	}
}

// MARK: - EnvironmentSection

private extension CreateStackCreatorView {
	struct EnvironmentSection: View {
		@Environment(CreateStackCreatorView.ViewModel.self) private var viewModel

		var body: some View {
			let environmentSorted = viewModel.stackEnvironment.sorted()

			NormalizedSection {
				ForEach(environmentSorted) { entry in
					Button {
						viewModel.environmentEditorMode = .edit(entry)
					} label: {
						LabeledContent {
							Text(entry.value)
								.multilineTextAlignment(.trailing)
						} label: {
							Text(entry.key)
						}
						.fullWidth(alignment: .leading)
					}
					.fontDesign(.monospaced)
//					.contextMenu {
//						Button(role: .destructive) {
//							Haptics.generateIfEnabled(.light)
//							viewModel.editEnvironmentEntry(old: entry, new: nil)
//						} label: {
//							Label("Generic.Remove", systemImage: SFSymbol.remove)
//						}
//						.labelStyle(.titleAndIcon)
//						.tint(.red)
//					}
					.swipeActions(edge: .trailing) {
						Button(role: .destructive) {
							Haptics.generateIfEnabled(.light)
							viewModel.editEnvironmentEntry(old: entry, new: nil)
						} label: {
							Label("Generic.Remove", systemImage: SFSymbol.remove)
						}
					}
				}

				Button {
					viewModel.environmentEditorMode = .add
				} label: {
					Label("Generic.Add", systemImage: SFSymbol.plus)
						.fullWidth(alignment: .leading)
				}
			} header: {
				Text("CreateStackCreatorView.EnvironmentSection.Header")
			} footer: {
				let randomKey = viewModel.stackEnvironment.randomElement()?.key
				let loc: LocalizedStringResource = if let randomKey {
					"CreateStackCreatorView.EnvironmentSection.FooterWithKey \(randomKey)"
				} else {
					"CreateStackCreatorView.EnvironmentSection.Footer"
				}
				Text(loc)
					.contentTransition(.opacity)
					.animation(.default, value: randomKey)
			}
			.animation(.default, value: environmentSorted)
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
						viewModel.networkEditorMode = .edit(network)
					} label: {
						Text(network.name)
							.fontDesign(.monospaced)
							.fullWidth(alignment: .leading)
					}
//					.contextMenu {
//						Button {
//							viewModel.networkEditorMode = .edit(network)
//						} label: {
//							Label("Generic.Edit", systemImage: SFSymbol.edit)
//						}
//						.labelStyle(.titleAndIcon)
//
//						Button(role: .destructive) {
//							viewModel.removeNetwork(network)
//						} label: {
//							Label("Generic.Remove", systemImage: SFSymbol.remove)
//						}
//						.labelStyle(.titleAndIcon)
//					}
					.swipeActions(edge: .trailing) {
						Button(role: .destructive) {
							viewModel.removeNetwork(network)
						} label: {
							Label("Generic.Remove", systemImage: SFSymbol.remove)
						}
					}
				}

				Button {
					viewModel.networkEditorMode = .add
				} label: {
					Label("Generic.Add", systemImage: SFSymbol.plus)
						.fullWidth(alignment: .leading)
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
			.environment(SceneDelegate())
	}
}
