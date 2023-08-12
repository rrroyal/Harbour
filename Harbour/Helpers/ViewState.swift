//
//  ViewState.swift
//  Harbour
//
//  Created by royal on 08/06/2023.
//

import SwiftUI

// MARK: - ViewState

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
	var unwrappedValue: Success? {
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
	var reloadingUnwrapped: Self {
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
}

// MARK: - ViewState+Identifiable

extension ViewState: Identifiable {
	/// ID of the state.
	var id: Int {
		switch self {
		case .loading:		0
		case .reloading:	-2
		case .success:		1
		case .failure:		2
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
	/// Background view for this state.
	@ViewBuilder
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
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.transition(.opacity)
		.animation(.easeInOut, value: self.id)
		.allowsHitTesting(false)
	}
}
