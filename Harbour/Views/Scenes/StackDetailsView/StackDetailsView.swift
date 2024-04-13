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
	@Environment(StacksView.ViewModel.self) private var stacksViewViewModel
	@Environment(SceneState.self) private var sceneState
	@Environment(\.errorHandler) private var errorHandler
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
						selectedStackName = stack.name
						sceneState.isStacksSheetPresented = false
					} label: {
						Label("StacksView.ShowContainers", systemImage: SFSymbol.container)
					}
				}
			}
		}
		.toolbar {
			if let stack = viewModel.stack {
				ToolbarItem(placement: .destructiveAction) {
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
		.background(viewState: viewModel.viewState, backgroundColor: .groupedBackground)
		.navigationTitle(navigationTitle)
		.animation(.easeInOut, value: viewModel.viewState)
		.animation(.easeInOut, value: viewModel.stack)
		.navigationDestination(for: Subdestination.self) { subdestination in
			switch subdestination {
			case .environment:
				StackEnvironmentView(entries: viewModel.stack?.env)
			}
		}
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
}

// MARK: - Previews

#Preview {
	StackDetailsView(navigationItem: .init(stackID: Stack.preview.id.description), selectedStackName: .constant(nil))
		.environmentObject(PortainerStore.preview)
}
