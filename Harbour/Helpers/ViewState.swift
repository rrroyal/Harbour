//
//  ViewState.swift
//  Harbour
//
//  Created by royal on 08/06/2023.
//  Copyright © 2023 shameful. All rights reserved.
//

import SwiftUI

// MARK: - ViewState

/// Enum indicating the state of a (optionally asynchronous) view.
enum ViewState<Success, Failure: Error> {
	/// View is loading.
	case loading

	/// View has data and is reloading.
	case reloading(Success?)

	/// View has data.
	case success(Success)

	/// Fetching the data failed.
	case failure(Failure)
}

extension ViewState {
	/// The `Success` value, or `nil` if missing.
	var value: Success? {
		switch self {
		case .loading:
			nil
		case .reloading(let success):
			success
		case .success(let success):
			success
		case .failure:
			nil
		}
	}

	/// `.loading`/`.reloading`-bound value, with unwrapped value.
	var reloading: Self {
		switch self {
		case .loading:
			.loading
		case .reloading(let success):
			.reloading(success)
		case .success(let success):
			.reloading(success)
		case .failure:
			.loading
		}
	}

	/// Is the current state a "loading" state?
	var isLoading: Bool {
		switch self {
		case .loading:
			true
		case .reloading:
			true
		case .success:
			false
		case .failure:
			false
		}
	}

	/// Should additional loading view be visible?
	var showAdditionalLoadingView: Bool {
		switch self {
		case .loading:
			return false
		case .reloading(let content):
			if let content = content as? any Collection {
				return !content.isEmpty
			}
			return true
		case .success:
			return false
		case .failure:
			return false
		}
	}
}

// MARK: - ViewState+Identifiable

extension ViewState: Identifiable {
	/// ID of the state.
	var id: Int {
		switch self {
		case .loading:
			0
		case .reloading:
			1
		case .success:
			2
		case .failure:
			-1
		}
	}
}

// MARK: - ViewState+Equatable

extension ViewState: Equatable where Success: Equatable {
	static func == (lhs: ViewState<Success, Failure>, rhs: ViewState<Success, Failure>) -> Bool {
		switch (lhs, rhs) {
		case (.loading, .loading):
			return true
		case (.reloading(let _lhs), .reloading(let _rhs)):
			return _lhs == _rhs
		case (.success(let _lhs), .success(let _rhs)):
			return _lhs == _rhs
		case (.failure(let _lhs), .failure(let _rhs)):
			return _lhs == _rhs
		default:
			return false
		}
	}
}

// MARK: - ViewState+backgroundView

extension ViewState {
	/// Background (or overlay) view for this state.
	@ViewBuilder @MainActor
	var backgroundView: some View {
		Group {
			switch self {
			case .loading:
				ProgressView()
					.accessibilityLabel("Generic.Loading")
			case .reloading(let content):
				if content == nil {
					ProgressView()
						.accessibilityLabel("Generic.Loading")
				} else {
					EmptyView()
				}
			case .success:
				EmptyView()
			case .failure(let failure):
				if let description = (failure as? LocalizedError)?.recoverySuggestion {
					ContentUnavailableView(failure.localizedDescription, systemImage: SFSymbol.error, description: Text(description))
				} else {
					ContentUnavailableView(failure.localizedDescription, systemImage: SFSymbol.error)
				}
			}
		}
		#if os(macOS)
		.controlSize(.small)
		#endif
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.transition(.opacity)
		.animation(.smooth, value: self.id)
		.allowsHitTesting(false)
	}
}
