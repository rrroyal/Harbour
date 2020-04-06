//
//  JSON.swift
//  Harbour
//
//  Created by royal on 16/03/2020.
//  Copyright © 2020 shameful. All rights reserved.
//

import SwiftyJSON

extension JSON {
	mutating func append(_ json: JSON, forKey: String?) {
		if (json.arrayValue.count <= 0 && json.dictionaryValue.count > 0) {
			// Dictionary
			if (forKey == nil) {
				return
			}
			
			if var dict = self.dictionary {
				dict[forKey ?? ""] = json
				self = JSON(dict)
			}
		} else if (json.arrayValue.count > 0 && json.dictionaryValue.count <= 0) {
			// Array
			if var arr = self.array {
				arr.append(json)
				self = JSON(arr)
			}
		}
	}
}
