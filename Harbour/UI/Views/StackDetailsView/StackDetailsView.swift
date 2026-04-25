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

	var body: some View {
		Form {
			GeneralSection(stack: viewModel.stack, navigationItem: navigationItem)
			StackAutoUpdateSection(autoUpdate: viewModel.stack?.autoUpdate)
			StackGitConfigSection(gitConfig: viewModel.stack?.gitConfig)
			StackEnvironmentSection(
				environment: viewModel.stack?.env,
				isStored: viewModel.stack?._isStored ?? true
			)
			StackFileContentsButton(
				stack: viewModel.stack,
				stackFileContent: viewModel.stackFileContent
			)
			StackShowContainersButton(
				stack: viewModel.stack,
				navigationItem: navigationItem
			)
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
			RemovingStackOverlay(
				stackName: viewModel.stack?.name ?? viewModel.navigationItem.stackName ?? viewModel.navigationItem.stackID,
				isRemoving: viewModel.isRemovingStack
			)
		}
		.environment(viewModel)
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
	}
}

// MARK: - Subviews

private extension StackDetailsView {
	struct GeneralSection: View {
		let stack: Stack?
		let navigationItem: NavigationItem

		var body: some View {
			NormalizedSection {
				LabeledContent("StackDetailsView.Section.General.Name") {
					LabeledText(stack?.name ?? navigationItem.stackName)
						.fontDesign(.monospaced)
						.multilineTextAlignment(.trailing)
						.textSelection(.enabled)
				}
				LabeledContent("StackDetailsView.Section.General.ID") {
					LabeledText(stack?.id.description ?? navigationItem.stackID)
						.multilineTextAlignment(.trailing)
						.textSelection(.enabled)
				}
				LabeledContent("StackDetailsView.Section.General.Status") {
					LabeledTextWithIcon(
						(stack?.status ?? Stack.Status?.none).title,
						systemImage: (stack?.status ?? Stack.Status?.none).icon
					)
					.imageScale(.medium)
					.labelStyle(.ordered(.labelIcon))
					.multilineTextAlignment(.trailing)
					.foregroundStyle((stack?.status ?? Stack.Status?.none).color)
				}
				LabeledContent("StackDetailsView.Section.General.Type") {
					LabeledText(stack?.type.title)
						.multilineTextAlignment(.trailing)
				}
			}
		}
	}

	struct StackAutoUpdateSection: View {
		let autoUpdate: Stack.AutoUpdate?

		var body: some View {
			if let autoUpdate {
				NormalizedSection {
					LabeledContent("StackDetailsView.Section.AutoUpdate.Interval") {
						LabeledText(autoUpdate.interval)
							.multilineTextAlignment(.trailing)
					}
					LabeledContent("StackDetailsView.Section.AutoUpdate.ForceUpdate") {
						LabeledText(autoUpdate.forceUpdate.description)
							.multilineTextAlignment(.trailing)
					}
					LabeledContent("StackDetailsView.Section.AutoUpdate.ForcePullImage") {
						LabeledText(autoUpdate.forcePullImage.description)
							.multilineTextAlignment(.trailing)
					}
				} header: {
					Text("StackDetailsView.Section.AutoUpdate")
				}
			}
		}
	}

	struct StackGitConfigSection: View {
		let gitConfig: Stack.GitConfig?

		var body: some View {
			if let gitConfig {
				NormalizedSection {
					if !gitConfig.referenceName.isReallyEmpty {
						LabeledContent("StackDetailsView.Section.GitConfig.ReferenceName") {
							LabeledText(gitConfig.referenceName)
								.fontDesign(.monospaced)
								.multilineTextAlignment(.trailing)
								.textSelection(.enabled)
						}
					}

					if !gitConfig.configFilePath.isReallyEmpty {
						LabeledContent("StackDetailsView.Section.GitConfig.ConfigFilePath") {
							LabeledText(gitConfig.configFilePath)
								.fontDesign(.monospaced)
								.multilineTextAlignment(.trailing)
								.textSelection(.enabled)
						}
					}

					LabeledContent("StackDetailsView.Section.GitConfig.URL") {
						Link(gitConfig.url.formatted(), destination: gitConfig.url)
							.fontDesign(.monospaced)
							.textSelection(.enabled)
					}
					.labeledContentStyle(.twoLine)
				} header: {
					Text("StackDetailsView.Section.GitConfig")
				}
			}
		}
	}

	struct StackEnvironmentSection: View {
		let environment: [Stack.EnvironmentEntry]?
		let isStored: Bool

		var body: some View {
			NormalizedSection {
				NavigationLink(value: Subdestination.environment(environment)) {
					Label("StackDetailsView.Environment", systemImage: SFSymbol.environment)
				}
				.disabled(isStored)
			}
		}
	}

	struct StackFileContentsButton: View {
		@Environment(ViewModel.self) private var viewModel
		@Environment(\.errorHandler) private var errorHandler

		let stack: Stack?
		let stackFileContent: String?

		var body: some View {
			NormalizedSection {
				Group {
					if let stackFileContent {
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
				.foregroundStyle(!(stack?._isStored ?? true) ? AnyShapeStyle(.accent) : AnyShapeStyle(.disabled))
				.disabled(stack?._isStored ?? true)
				.id(ViewID.stackFileButton)
			}
		}

		private func fetchStackFile() {
			Task {
				do {
					try await viewModel.fetchStackFile().value
				} catch {
					errorHandler(error)
				}
			}
		}
	}

	struct StackShowContainersButton: View {
		@Environment(SceneDelegate.self) private var sceneDelegate

		let stack: Stack?
		let navigationItem: NavigationItem

		var body: some View {
			NormalizedSection {
				Button {
					if let stackName = stack?.name ?? navigationItem.stackName {
						filterByStackName(stackName)
					}
				} label: {
					Label("StacksView.ShowContainers", image: SFSymbol.Custom.container)
#if os(macOS)
						.frame(maxWidth: .infinity, alignment: .leading)
						.contentShape(Rectangle())
#endif
				}
				.foregroundStyle((stack?.isOn ?? false) ? AnyShapeStyle(.accent) : AnyShapeStyle(.disabled))
				.disabled(!(stack?.isOn ?? false))
			}
		}

		private func filterByStackName(_ stackName: String?) {
			sceneDelegate.navigate(to: .containers)
			sceneDelegate.selectedStackNameForContainersView = stackName
		}
	}

	struct RemovingStackOverlay: View {
		let stackName: String
		let isRemoving: Bool

		var body: some View {
			if isRemoving {
				VStack {
					ProgressView()
						.controlSize(.large)

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
	}
}

// MARK: - Actions

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
