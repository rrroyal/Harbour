//
//  IntentHandler.swift
//  HarbourIntents
//
//  Created by royal on 03/10/2022.
//

import Intents
import os.log

final class IntentHandler: INExtension {
	override func handler(for intent: INIntent) -> Any {
		switch intent {
			case is ContainerStateIntent:
				return ContainerStateIntentHandler()
//			case is ExecuteActionIntent:
//				return ExecuteActionIntentHandler()
			default:
				return self
		}
	}

}
