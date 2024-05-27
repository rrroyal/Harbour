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
	@Environment(SceneDelegate.self) private var sceneDelegate
	@Environment(\.dismiss) private var dismiss
	@Environment(\.errorHandler) private var errorHandler
	@Environment(\.presentIndicator) private var presentIndicator
	@Environment(\.portainerServerURL) private var portainerServerURL
	@State private var viewModel: ViewModel

	var navigationItem: NavigationItem

	private var navigationTitle: String {
		viewModel.stack?.name ?? navigationItem.stackName ?? navigationItem.stackID.description
	}

	init(navigationItem: NavigationItem) {
		self.navigationItem = navigationItem

		let viewModel = ViewModel(navigationItem: navigationItem)
		self._viewModel = .init(wrappedValue: viewModel)
	}

	@ViewBuilder
	private var stackDetailsContent: some View {
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
				Label(stack.status.title, systemImage: stack.status.icon)
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
				NavigationLink(value: Subdestination.environment(viewModel.stack?.env)) {
					Label("StackDetailsView.Environment", systemImage: SFSymbol.environment)
				}
			}

			NormalizedSection {
				Button {
					Haptics.generateIfEnabled(.light)
					filterByStackName(stack.name)
				} label: {
					Label("StacksView.ShowContainers", image: SFSymbol.Custom.container)
						#if os(macOS)
						.frame(maxWidth: .infinity, alignment: .leading)
						.contentShape(Rectangle())
						#endif
				}
				.foregroundStyle(stack.isOn ? AnyShapeStyle(.accent) : AnyShapeStyle(.disabled))
				.disabled(!stack.isOn)
			}

			NormalizedSection {
				Group {
					if let stackFileContents = viewModel.stackFileContents {
						ShareLink(item: stackFileContents) {
							Label("StackDetailsView.StackFile.Share", systemImage: SFSymbol.share)
								#if os(macOS)
								.frame(maxWidth: .infinity, alignment: .leading)
								.contentShape(Rectangle())
								#endif
						}
					} else {
						Button {
							Haptics.generateIfEnabled(.light)
							fetchStackFile()
						} label: {
							HStack {
								Label("StackDetailsView.StackFile.Download", systemImage: "arrow.down.doc")

								Spacer()

								if viewModel.isFetchingStackFileContents {
									ProgressView()
										#if os(macOS)
										.controlSize(.small)
										#endif
								}
							}
							#if os(macOS)
							.frame(maxWidth: .infinity, alignment: .leading)
							.contentShape(Rectangle())
							#endif
						}
						.disabled(viewModel.isFetchingStackFileContents)
					}
				}
				.id(ViewID.stackFileButton)
				.foregroundStyle(.accent)
			}
		}
	}

	@ToolbarContentBuilder
	private var toolbarContent: some ToolbarContent {
		if !viewModel.isRemovingStack, let stack = viewModel.stack {
			ToolbarItem(placement: .primaryAction) {
				Menu {
					StackContextMenu(stack: stack) {
						setStackState(stack, started: $0)
					} removeStackAction: {
						confirmRemoveStack()
					}
				} label: {
					Label("Generic.More", systemImage: SFSymbol.moreCircle)
						.labelStyle(.automatic)
				}
				.labelStyle(.titleAndIcon)
			}
		}

//		ToolbarItem(placement: .status) {
//			DelayedView(isVisible: viewModel.isStatusProgressViewVisible) {
//				ProgressView()
//			}
//			.transition(.opacity)
//		}
	}

	var body: some View {
		Form {
			stackDetailsContent
		}
		.formStyle(.grouped)
		#if os(macOS)
		.buttonStyle(.plain)
		#endif
		.toolbar {
			toolbarContent
		}
		#if os(iOS)
		.background(viewState: viewModel.viewState, backgroundColor: .groupedBackground)
		#elseif os(macOS)
		.background(viewState: viewModel.viewState, backgroundColor: .clear)
		#endif
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
		.confirmationDialog(
			"Generic.AreYouSure?",
			isPresented: $viewModel.isRemoveStackAlertPresented,
			titleVisibility: .visible,
			presenting: viewModel.stack
		) { stack in
			Button("Generic.Remove", role: .destructive) {
				Haptics.generateIfEnabled(.heavy)
				removeStack(stack)
			}
		} message: { stack in
			Text("StacksView.RemoveStackAlert.Message StackName:\(stack.name)")
		}
		.navigationDestination(for: Subdestination.self) { subdestination in
			switch subdestination {
			case .environment(let environment):
				StackEnvironmentView(entries: environment)
			}
		}
		.navigationTitle(navigationTitle)
		.animation(.easeInOut, value: viewModel.viewState)
		.animation(.easeInOut, value: viewModel.stackFileViewState)
		.animation(.easeInOut, value: viewModel.stack)
		.animation(.easeInOut, value: viewModel.isRemovingStack)
		.animation(.easeInOut, value: viewModel.isStatusProgressViewVisible)
		.userActivity(HarbourUserActivityIdentifier.stackDetails, isActive: sceneDelegate.activeTab == .stacks) { userActivity in
			viewModel.createUserActivity(userActivity)
		}
		.task {
			await fetch().value
		}
		.refreshable(binding: $viewModel.scrollViewIsRefreshing) {
			await fetch().value
		}
		.onChange(of: navigationItem) { _, newNavigationItem in
			viewModel.navigationItem = newNavigationItem
		}
		.id(self.id)
	}
}

// MARK: - StackDetailsView+Actions

private extension StackDetailsView {
	@discardableResult
	func fetch() -> Task<Void, Never> {
		Task {
			do {
				try await viewModel.getStack(stackID: Stack.ID(navigationItem.stackID) ?? -1).value
			} catch {
				errorHandler(error)
			}
		}
	}

	@discardableResult
	func fetchStackFile() -> Task<Void, Never> {
		Task {
			do {
				try await viewModel.fetchStackFile().value
			} catch {
				errorHandler(error)
			}
		}
	}

	func filterByStackName(_ stackName: String?) {
		sceneDelegate.navigate(to: .containers)
		sceneDelegate.selectedStackName = stackName
	}

	func setStackState(_ stack: Stack, started: Bool) {
		Task {
			do {
				presentIndicator(.stackStartOrStop(stack.name, started: started, state: .loading))
				try await viewModel.setStackState(stack, started: started)
				presentIndicator(.stackStartOrStop(stack.name, started: started, state: .success))
			} catch {
				presentIndicator(.stackStartOrStop(stack.name, started: started, state: .failure(error)))
				errorHandler(error, showIndicator: false)
			}
		}
	}

	func confirmRemoveStack() {
		viewModel.isRemoveStackAlertPresented = true
	}

	func removeStack(_ stack: Stack) {
		Task {
			do {
				presentIndicator(.stackRemove(stack.name, stack.id, state: .loading))

				viewModel.isRemovingStack = true
				try await viewModel.removeStack(stack)

				presentIndicator(.stackRemove(stack.name, stack.id, state: .success))
				dismiss()
			} catch {
				presentIndicator(.stackRemove(stack.name, stack.id, state: .failure(error)))
				viewModel.isRemovingStack = false
				errorHandler(error, showIndicator: false)
			}
		}
	}
}

// MARK: - StackDetailsView+Identifiable

extension StackDetailsView: Identifiable {
	var id: String {
		"\(Self.self).\(navigationItem.id)"
	}
}

// MARK: - StackDetailsView+Equatable

extension StackDetailsView: Equatable {
	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.navigationItem == rhs.navigationItem
	}
}

// MARK: - StackDetailsView+ViewID

private extension StackDetailsView {
	enum ViewID {
		case stackFileButton
	}
}

// MARK: - Previews

#Preview {
	StackDetailsView(navigationItem: .init(stackID: Stack.preview().id.description, stackName: Stack.preview().name))
		.withEnvironment(appState: .shared)
}
