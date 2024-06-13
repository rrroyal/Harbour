//
//  _Sendable.swift
//  Harbour
//
//  Created by royal on 15/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import OSLog
import SwiftUI

extension DismissAction: @unchecked Sendable { }

extension Logger: @unchecked Sendable { }

extension NSItemProvider: @unchecked @retroactive Sendable { }

extension UserDefaults: @unchecked @retroactive Sendable { }
