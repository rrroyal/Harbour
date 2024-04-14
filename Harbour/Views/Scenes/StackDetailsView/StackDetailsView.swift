//
//  StackDetailsView.swift
//  Harbour
//
//  Created by royal on 03/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonHaptics
import PortainerKit
import SwiftUI

// MARK: - StackDetailsView

struct StackDetailsView: View {
	@EnvironmentObject private var portainerStore: PortainerStore
	@Environment(StacksView.ViewModel.self) private var stacksViewViewModel
	@Environment(SceneState.self) private var sceneState
	@Environment(\.dismiss) private var dismiss
	@Environment(\.errorHandler) private var errorHandler
	@Environment(\.presentIndicator) private var presentIndicator
	@State private var viewModel: ViewModel

	@Binding var selectedStackName: String?

	private var navigationTitle: String {
		viewModel.stack?.name ??
			stacksViewViewModel.stacks?.first(where: { $0.id == viewModel.navigationItem.id.description })?.name ??
			viewModel.navigationItem.stackID.description
	}

	init(navigationItem: NavigationItem, selectedStackName: Binding<String?>) {
		self.viewModel = .init(navigationItem: navigationItem)
		self._selectedStackName = selectedStackName
	}

	var body: some View {
		Form {
			if let stack = viewModel.stack {
				NormalizedSection {
					Text(stack.name)
						.textSelection(.enabled)
						.fontDesign(.monospaced)
				} header: {
					Text("StackDetailsView.Section.Name")
				}

				NormalizedSection {
					Text(stack.id.description)
						.textSelection(.enabled)
						.fontDesign(.monospaced)
				} header: {
					Text("StackDetailsView.Section.ID")
				}

				NormalizedSection {
					Text(stack.status.title)
						.foregroundStyle(stack.status.color)
				} header: {
					Text("StackDetailsView.Section.Status")
				}

				NormalizedSection {
					Text(stack.type.title)
				} header: {
					Text("StackDetailsView.Section.Type")
				}

				NormalizedSection {
					NavigationLink(value: Subdestination.environment) {
						Label("StackDetailsView.Environment", systemImage: SFSymbol.environment)
					}
				}

				NormalizedSection {
					Button {
						viewModel.isStackFileSheetPresented = true
					} label: {
						Label("StacksView.GetStackFile", systemImage: "arrow.down.doc")
					}

					Button {
						selectedStackName = stack.name
						sceneState.isStacksSheetPresented = false
					} label: {
						Label("StacksView.ShowContainers", systemImage: SFSymbol.container)
					}
				}

				NormalizedSection {
					Button(role: .destructive) {
						Haptics.generateIfEnabled(.warning)
						viewModel.isStackRemovalAlertPresented = true
					} label: {
						Label("StacksView.RemoveStack", systemImage: SFSymbol.remove)
					}
					.foregroundStyle(.red)
				}
			}
		}
		.toolbar {
			if let stack = viewModel.stack {
				ToolbarItem(placement: .destructiveAction) {
					if !viewModel.isRemovingStack {
						Group {
							if stacksViewViewModel.loadingStacks.contains(stack.id.description) {
								ProgressView()
							} else {
								Button {
									setStackState(stack, started: !stack.isOn)
								} label: {
									Label(
										stack.isOn ? "StacksView.Stack.Stop" : "StacksView.Stack.Start",
										systemImage: stack.isOn ? SFSymbol.stop : SFSymbol.start
									)
								}
								.symbolVariant(.fill)
							}
						}
						.transition(.opacity)
					}
				}
			}
		}
		.background(viewState: viewModel.viewState, backgroundColor: .groupedBackground)
		.overlay {
			if viewModel.isRemovingStack {
				VStack {
					ProgressView()
						.controlSize(.large)

					let stackName = viewModel.stack?.name ?? viewModel.navigationItem.stackName ?? "ID:\(viewModel.navigationItem.stackID)"
					Text("StackDetailsView.RemovingStack StackName:\(stackName)")
						.font(.title2)
						.fontWeight(.medium)
						.foregroundStyle(.secondary)
						.padding(.top)
				}
				.padding()
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.background(Material.regular, ignoresSafeAreaEdges: .all)
			}
		}
		.sheet(isPresented: $viewModel.isStackFileSheetPresented) {
			DownloadStackFileView(stackID: viewModel.navigationItem.stackID)
				.presentationDetents([.fraction(0.18)])
				.presentationDragIndicator(.hidden)
				.presentationContentInteraction(.resizes)
				.environment(viewModel)
		}
		.confirmationDialog(
			"Generic.AreYouSure?",
			isPresented: $viewModel.isStackRemovalAlertPresented,
			titleVisibility: .visible,
			presenting: viewModel.stack
		) { _ in
			Button("Generic.Remove", role: .destructive) {
				removeStack()
			}
		} message: { stack in
			Text("StackDetailsView.StackRemovalAlert.Message StackName:\(stack.name)")
		}
		.navigationTitle(navigationTitle)
		.navigationDestination(for: Subdestination.self) { subdestination in
			switch subdestination {
			case .environment:
				StackEnvironmentView(entries: viewModel.stack?.env)
			}
		}
		.animation(.easeInOut, value: viewModel.viewState)
		.animation(.easeInOut, value: viewModel.stack)
		.animation(.easeInOut, value: viewModel.isRemovingStack)
		.task { await fetch() }
		.refreshable { await fetch() }
	}
}

// MARK: - StackDetailsView+Actions

private extension StackDetailsView {
	@MainActor
	func fetch() async {
		do {
			try await viewModel.getStack().value
		} catch {
			errorHandler(error)
		}
	}

	@MainActor
	func setStackState(_ stack: Stack, started: Bool) {
		Task {
			do {
				Haptics.generateIfEnabled(.light)
				try await stacksViewViewModel.setStackState(stack, started: started)
				try await viewModel.getStack().value
			} catch {
				errorHandler(error)
			}
		}
	}

	@MainActor
	func removeStack() {
		Haptics.generateIfEnabled(.heavy)
		Task {
			do {
				viewModel.isRemovingStack = true
				try await viewModel.removeStack().value
				stacksViewViewModel.getStacks(includingContainers: true)
				dismiss()

				let stackName = viewModel.stack?.name ?? viewModel.navigationItem.stackName ?? "ID:\(viewModel.navigationItem.stackID)"
				presentIndicator(.stackRemoved(stackName))
			} catch {
				viewModel.isRemovingStack = false
				errorHandler(error)
			}
		}
	}
}

// MARK: - Previews

#Preview {
	StackDetailsView(navigationItem: .init(stackID: Stack.preview.id.description), selectedStackName: .constant(nil))
		.environmentObject(PortainerStore.preview)
}
