//
//  Error+isCancellationError.swift
//  Harbour
//
//  Created by royal on 03/11/2022.
//

import Foundation

extension Error {
	var isCancellationError: Bool {
		switch self {
			case is CancellationError:
				return true
			case let error as URLError:
				return error.code == URLError.cancelled
			default:
				return false
		}
	}
}
