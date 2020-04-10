//
//  Date.swift
//  Harbour
//
//  Created by royal on 15/03/2020.
//  Copyright © 2020 shameful. All rights reserved.
//

import Foundation

extension Date {
	var timestampString: String? {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .abbreviated
		formatter.maximumUnitCount = 2
		formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]

		guard let timeString = formatter.string(from: self, to: Date()) else {
			return nil
		}

		let formatString = NSLocalizedString("%@", comment: "")
		return String(format: formatString, timeString)
   }
}
