//
//  Date+.swift
//  Harbour
//
//  Created by royal on 14/10/2021.
//

import Foundation

extension Date {
	func formatted() -> String {
		let formatter = DateFormatter()
		formatter.timeZone = TimeZone.autoupdatingCurrent
		formatter.calendar = Calendar.autoupdatingCurrent
		formatter.locale = Locale.autoupdatingCurrent
		formatter.dateStyle = .medium
		formatter.timeStyle = .medium
		formatter.doesRelativeDateFormatting = false
		formatter.formattingContext = .standalone
		
		return formatter.string(from: self)
	}
}
