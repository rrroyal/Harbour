//
//  CreateStackView.swift
//  Harbour
//
//  Created by royal on 14/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import CommonHaptics
import PortainerKit
import SwiftUI
import UniformTypeIdentifiers

// MARK: - CreateStackView

struct CreateStackView: View {
	@Environment(SceneDelegate.self) private var sceneDelegate
	@Environment(\.dismiss) private var dismiss
	@Environment(\.errorHandler) private var errorHandler
	@Environment(\.presentIndicator) private var presentIndicator
	@State private var viewModel: ViewModel
	@FocusState private var focusedField: FocusedField?

	var onEnvironmentEdit: (([KeyValueEntry]) -> Void)?
	var onStackFileSelection: ((String?) -> Void)?
	var onStackCreation: ((Stack) -> Void)?

	init(
		existingStack: Stack? = nil,
		onEnvironmentEdit: (([KeyValueEntry]) -> Void)? = nil,
		onStackFileSelection: ((String?) -> Void)? = nil,
		onStackCreation: ((Stack) -> Void)? = nil
	) {
		let viewModel = ViewModel()
		if let existingStack {
			viewModel.stackID = existingStack.id
			viewModel.stackName = existingStack.name
			viewModel.stackEnvironment = existingStack.env?.map { .init(key: $0.name, value: $0.value) } ?? []
		}
		self._viewModel = .init(initialValue: viewModel)

		self.onEnvironmentEdit = onEnvironmentEdit
		self.onStackFileSelection = onStackFileSelection
		self.onStackCreation = onStackCreation
	}

	private let allowedContentTypes: [UTType] = [
		.yaml,
		.text,
		.plainText
	]

	@ViewBuilder @MainActor
	private var createButton: some View {
		Button {
			submitStack()
		} label: {
			if viewModel.isLoading {
				ProgressView()
					#if os(macOS)
					.controlSize(.small)
					#endif
			} else if let error = viewModel.createStackError {
				Text(error.localizedDescription)
			} else {
				Label(
					viewModel.shouldCreateNewStack ? "CreateStackView.Create" : "CreateStackView.Update",
					systemImage: viewModel.shouldCreateNewStack ? SFSymbol.plus : SFSymbol.update
				)
			}
		}
		.keyboardShortcut(.defaultAction)
		.disabled(!viewModel.canCreateStack)
		.disabled(viewModel.isLoading)
		.animation(.default, value: viewModel.canCreateStack)
	}

	var body: some View {
		Form {
			NormalizedSection {
				TextField("CreateStackView.Name", text: $viewModel.stackName)
					.fontDesign(.monospaced)
					.autocorrectionDisabled()
					.labelsHidden()
					.submitLabel(viewModel.canCreateStack ? .send : .continue)
					.onSubmit(submitStack)
					.focused($focusedField, equals: .textfieldName)
			} header: {
				Text("CreateStackView.Name")
			}

			StackFileContentView(
				allowedContentTypes: allowedContentTypes,
				onStackFileSelection: onStackFileSelection
			)
			.transition(.opacity)
			.onChange(of: viewModel.stackFileContent) { _, newStackFileContent in
				focusedField = nil
				onStackFileSelection?(newStackFileContent)
			}

			StackEnvironmentView()
				.onChange(of: viewModel.stackEnvironment) { _, newEntries in
					focusedField = nil
					onEnvironmentEdit?(newEntries)
				}
		}
		.formStyle(.grouped)
		.scrollDismissesKeyboard(.interactively)
//		.navigationTitle(navigationTitle)
		#if os(iOS)
		.safeAreaInset(edge: .bottom) {
			createButton
				.buttonStyle(.customPrimary(backgroundColor: viewModel.createStackError != nil ? .red : .accentColor))
				.padding()
				.background(Color.groupedBackground)
		}
		#endif
		.fileImporter(isPresented: $viewModel.isFileImportSheetPresented, allowedContentTypes: allowedContentTypes) { result in
			handleStackFileResult(result)
		}
		.sheet(isPresented: $viewModel.isEnvironmentEntrySheetPresented) {
			viewModel.editedEnvironmentEntry = nil
		} content: {
			let oldEntry = viewModel.editedEnvironmentEntry
			NavigationStack {
				KeyValueEditView(entry: oldEntry) { newEntry in
					viewModel.editEnvironmentEntry(old: oldEntry, new: newEntry)
				} removeAction: {
					if let oldEntry {
						viewModel.editEnvironmentEntry(old: oldEntry, new: nil)
					}
				}
				#if os(iOS)
				.navigationBarTitleDisplayMode(.inline)
				#endif
				.navigationTitle(oldEntry != nil ? "CreateStackView.EditEnvironmentValue" : "CreateStackView.AddEnvironmentValue")
				.addingCloseButton()
			}
			.presentationDetents([.medium])
			.presentationDragIndicator(.hidden)
			.presentationContentInteraction(.resizes)
			#if os(macOS)
			.sheetMinimumFrame(width: 320, height: 240)
			#endif
		}
		.toolbar {
			#if os(macOS)
			ToolbarItem(placement: .primaryAction) {
				createButton
			}
			#endif
		}
		.environment(viewModel)
		.navigationTitle(viewModel.shouldCreateNewStack ? "CreateStackView.Title.Create" : "CreateStackView.Title.Update")
		.animation(.default, value: viewModel.isLoading)
		.animation(.default, value: viewModel.isLoadingStackFileContent)
		.animation(.default, value: viewModel.isStackFileContentExpanded)
		.animation(.default, value: viewModel.stackFileContent)
		.animation(.default, value: viewModel.stackEnvironment)
		.animation(.default, value: viewModel.createStackError != nil)
		.task(id: viewModel.stackID) {
			if viewModel.stackID != nil {
				await viewModel.fetchStackFileContent().value
			}
		}
	}
}

// MARK: - CreateStackView+FocusedField

private extension CreateStackView {
	enum FocusedField {
		case textfieldName
	}
}

// MARK: - CreateStackView+Actions

private extension CreateStackView {
	@MainActor
	func submitStack() {
		Task {
			guard viewModel.canCreateStack else { return }

			let stackName = viewModel.stackName

			do {
				Haptics.generateIfEnabled(.buttonPress)

				let stack = try await viewModel.createOrUpdateStack().value

				let indicatorAction: @Sendable () -> Void = {
					Haptics.generateIfEnabled(.soft)
					let navigationItem = StackDetailsView.NavigationItem(stackID: stack.id.description, stackName: stack.name)
					Task { @MainActor in
						sceneDelegate.resetSheets()
						sceneDelegate.navigate(to: .stacks, with: navigationItem)
					}
				}
				if viewModel.shouldCreateNewStack {
					presentIndicator(.stackCreate(stackName: stackName, state: .success, action: indicatorAction))
				} else {
					presentIndicator(.stackUpdate(stackName: stackName, state: .success, action: indicatorAction))
				}
				Haptics.generateIfEnabled(.success)
				onStackCreation?(stack)

				dismiss()
			} catch {
				if viewModel.shouldCreateNewStack {
					presentIndicator(.stackCreate(stackName: stackName, state: .failure(error)))
				} else {
					presentIndicator(.stackUpdate(stackName: stackName, state: .failure(error)))
				}
				errorHandler(error, showIndicator: false)
			}
		}
	}

	func handleStackFileResult(_ result: Result<URL, Error>) {
		do {
			let url = try result.get()
			let stackFileContent = try viewModel.loadStackFile(at: url, securityScopedResource: true)
			Haptics.generateIfEnabled(.selectionChanged)
			onStackFileSelection?(stackFileContent)
		} catch {
			errorHandler(error)
		}
	}
}

// MARK: - Previews

#Preview {
	NavigationStack {
		CreateStackView()
	}
}
