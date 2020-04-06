//
//  UIApplication.swift
//  Harbour
//
//  Created by royal on 17/03/2020.
//  Copyright © 2020 shameful. All rights reserved.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
