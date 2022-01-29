//
//  IntentHandler.swift
//  Siri Intents
//
//  Created by royal on 15/01/2022.
//

import Intents
import os.log

class IntentHandler: INExtension {
	internal static let logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Intents")
	
    override func handler(for intent: INIntent) -> Any {
		switch intent {
			case is GetContainerStatusIntent:
				return GetContainerStatusIntentHandler()
			case is ExecuteActionIntent:
				return ExecuteActionIntentHandler()
			default:
				return self
		}
    }
    
}
