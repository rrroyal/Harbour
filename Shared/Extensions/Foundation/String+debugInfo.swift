//
//  String+debugInfo.swift
//  Harbour
//
//  Created by royal on 23/09/2022.
//

import Foundation

extension String {
	/// Returns `String` with debug information, useful for logging.
	/// - Parameters:
	///   - _function: Function name
	///   - _fileID: File ID
	///   - _line: Line of the statement
	/// - Returns: `String`
	static func debugInfo(_function: StaticString = #function, _fileID: StaticString = #fileID, _line: Int = #line) -> Self {
		#if DEBUG
		"\(_function) \(_fileID):\(_line)"
		#else
		"\(_function)"
		#endif
	}
}
