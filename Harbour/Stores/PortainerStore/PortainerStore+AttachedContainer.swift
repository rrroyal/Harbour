//
//  PortainerStore+AttachedContainer.swift
//  Harbour
//
//  Created by royal on 11/04/2024.
//  Copyright © 2024 shameful. All rights reserved.
//

import PortainerKit

extension PortainerStore {
	class AttachedContainer: Identifiable {
		var container: Container
		var subject: WebSocketPassthroughSubject

		var id: Container.ID {
			container.id
		}

		init(container: Container, subject: WebSocketPassthroughSubject) {
			self.container = container
			self.subject = subject
		}

		deinit {
			subject.send(completion: .finished)
		}
	}
}
