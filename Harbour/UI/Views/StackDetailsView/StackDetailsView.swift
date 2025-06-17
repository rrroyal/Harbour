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

	let navigationItem: NavigationItem

	private var navigationTitle: String {
		viewModel.stack?.name ?? navigationItem.stackName ?? navigationItem.stackID.description
	}

	init(navigationItem: NavigationItem) {
		self.navigationItem = navigationItem

		let viewModel = ViewModel(navigationItem: navigationItem)
		self.viewModel = viewModel
	}

	@ViewBuilder
	private var removingStackOverlay: some View {
		if viewModel.isRemovingStack {
			VStack {
				ProgressView()
					.controlSize(.large)

				let stackName = viewModel.stack?.name ?? viewModel.navigationItem.stackName ?? viewModel.navigationItem.stackID
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

	@ToolbarContentBuilder
	private var toolbarContent: some ToolbarContent {
		ToolbarItem(placement: .primaryAction) {
			Menu {
				if viewModel.viewState.isLoading {
					Text("Generic.Loading")
					Divider()
				}

				if !viewModel.isRemovingStack, let stack = viewModel.stack {
					StackContextMenu(
						stack: stack,
						setStackStateAction: { setStackState(stack, started: $0) }
					)
				}
			} label: {
				Label("Generic.More", systemImage: SFSymbol._moreToolbar)
					.labelStyle(.automatic)
			}
			.labelStyle(.titleAndIcon)
		}

//		ToolbarItem(placement: .status) {
//			DelayedView(isVisible: viewModel.isStatusProgressViewVisible) {
//				ProgressView()
//			}
//		}
	}

	var body: some View {
		Form {
			// Stack Status
			NormalizedSection {
				Label(
					(viewModel.stack?.status ?? Stack.Status?.none).title,
					systemImage: (viewModel.stack?.status ?? Stack.Status?.none).icon
				)
				.foregroundStyle((viewModel.stack?.status ?? Stack.Status?.none).color)
			} header: {
				Text("StackDetailsView.Section.Status")
			}

			// Stack Name
			if let stackName = viewModel.stack?.name ?? navigationItem.stackName {
				NormalizedSection {
					Text(stackName)
						.textSelection(.enabled)
						.fontDesign(.monospaced)
				} header: {
					Text("StackDetailsView.Section.Name")
				}
			}

			// Stack ID
			NormalizedSection {
				Text(viewModel.stack?.id.description ?? navigationItem.stackID)
					.textSelection(.enabled)
					.fontDesign(.monospaced)
			} header: {
				Text("StackDetailsView.Section.ID")
			}

			// Stack Type
			NormalizedSection {
				Text((viewModel.stack?.type ?? Stack.StackType?.none).title)
			} header: {
				Text("StackDetailsView.Section.Type")
			}

			// Environment
			NormalizedSection {
				NavigationLink(value: Subdestination.environment(viewModel.stack?.env)) {
					Label("StackDetailsView.Environment", systemImage: SFSymbol.environment)
				}
				.disabled(viewModel.stack?._isStored ?? true)
			}

			// Show Containers Button
			NormalizedSection {
				Button {
					if let stackName = viewModel.stack?.name ?? navigationItem.stackName {
						filterByStackName(stackName)
					}
				} label: {
					Label("StacksView.ShowContainers", image: SFSymbol.Custom.container)
						#if os(macOS)
						.frame(maxWidth: .infinity, alignment: .leading)
						.contentShape(Rectangle())
						#endif
				}
				.foregroundStyle((viewModel.stack?.isOn ?? false) ? AnyShapeStyle(.accent) : AnyShapeStyle(.disabled))
				.disabled(!(viewModel.stack?.isOn ?? false))
			}

			// Stack File Contents Button
			NormalizedSection {
				Group {
					if let stackFileContent = viewModel.stackFileContent {
						ShareLink(item: stackFileContent) {
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

								if viewModel.isFetchingStackFileContent {
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
						.disabled(viewModel.isFetchingStackFileContent)
					}
				}
				.foregroundStyle(!(viewModel.stack?._isStored ?? true) ? AnyShapeStyle(.accent) : AnyShapeStyle(.disabled))
				.disabled(viewModel.stack?._isStored ?? true)
				.id(ViewID.stackFileButton)
			}
		}
		.formStyle(.grouped)
		#if os(macOS)
		.buttonStyle(.plain)
		#endif
		.toolbar {
			toolbarContent
		}
		#if os(iOS)
		.viewStateBackground(viewModel.viewState, backgroundColor: .groupedBackground)
		#elseif os(macOS)
		.viewStateBackground(viewModel.viewState, backgroundColor: .clear)
		#endif
		.overlay {
			removingStackOverlay
		}
		.navigationTitle(navigationTitle)
		.navigationDestination(for: Subdestination.self) { subdestination in
			switch subdestination {
			case .environment(let environment):
				StackEnvironmentView(entries: environment)
			}
		}
		.animation(.default, value: viewModel.viewState)
		.animation(.default, value: viewModel.stackFileViewState)
		.animation(.default, value: viewModel.stack)
		.animation(.default, value: viewModel.isRemovingStack)
//		.animation(.default, value: viewModel.isStatusProgressViewVisible)
		.animation(nil, value: navigationItem)
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
//		.id(self.id)
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
		sceneDelegate.selectedStackNameForContainersView = stackName
	}

	func setStackState(_ stack: Stack, started: Bool) {
		Task {
			do {
				presentIndicator(.stackStartOrStop(stackName: stack.name, started: started, state: .loading))
				try await viewModel.setStackState(stack, started: started)
				presentIndicator(.stackStartOrStop(stackName: stack.name, started: started, state: .success))
			} catch {
				presentIndicator(.stackStartOrStop(stackName: stack.name, started: started, state: .failure(error)))
				errorHandler(error, showIndicator: false)
			}
		}
	}
}

// MARK: - StackDetailsView+Identifiable

extension StackDetailsView: Identifiable {
	nonisolated var id: String {
		"\(Self.self).\(navigationItem.id)"
	}
}

// MARK: - StackDetailsView+Equatable

extension StackDetailsView: Equatable {
	nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
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
		.withEnvironment()
		.environment(SceneDelegate())
}
