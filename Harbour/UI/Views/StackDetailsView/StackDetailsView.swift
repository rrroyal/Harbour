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

				Button(role: .destructive) {
					Haptics.generateIfEnabled(.warning)
					viewModel.isStackRemovalAlertPresented = true
				} label: {
					Label("StackDetailsView.RemoveStack", systemImage: SFSymbol.remove)
						#if os(macOS)
						.frame(maxWidth: .infinity, alignment: .leading)
						.contentShape(Rectangle())
						#endif
				}
				.foregroundStyle(.red)
			}
		}
	}

	@ToolbarContentBuilder
	private var toolbarContent: some ToolbarContent {
		if let stack = viewModel.stack {
			ToolbarItem(placement: .destructiveAction) {
				if !viewModel.isRemovingStack {
					Group {
						if portainerStore.loadingStacks.contains(stack.id) {
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
				Haptics.generateIfEnabled(.light)
				try await viewModel.fetchStackFile().value
			} catch {
				errorHandler(error)
			}
		}
	}

	func setStackState(_ stack: Stack, started: Bool) {
		Task {
			do {
				Haptics.generateIfEnabled(.light)
				try await viewModel.setStackState(stack.id, started: started)
			} catch {
				errorHandler(error)
			}
		}
	}

	func filterByStackName(_ stackName: String?) {
		Haptics.generateIfEnabled(.light)
		sceneDelegate.navigate(to: .containers)
		sceneDelegate.selectedStackName = stackName
	}

	func removeStack() {
		Haptics.generateIfEnabled(.heavy)
		Task {
			do {
				viewModel.isRemovingStack = true
				try await viewModel.removeStack().value
				portainerStore.refreshStacks()
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
