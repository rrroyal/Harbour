//
//  Error+.swift
//  Harbour
//
//  Created by royal on 23/01/2022.
//

import Foundation

extension Error {
	var readableDescription: String {
		(self as? LocalizedError)?.errorDescription ?? self.localizedDescription
	}
}
