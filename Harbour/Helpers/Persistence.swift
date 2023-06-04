//
//  Persistence.swift
//  Harbour
//
//  Created by royal on 23/09/2022.
//

import CoreData
import OSLog
import CommonFoundation
import CommonOSLog

struct Persistence {
	static let shared = Persistence()

	private static let logger = Logger(category: Logger.Category.persistence)

	let container: NSPersistentContainer
	let backgroundContext: NSManagedObjectContext

	init(inMemory: Bool = false) {
		container = NSPersistentContainer(name: "Harbour")

		if inMemory {
			container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
		}

		container.loadPersistentStores { storeDescription, error in
			if let error = error as NSError? {
				/*
				 Typical reasons for an error here include:
				 * The parent directory does not exist, cannot be created, or disallows writing.
				 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
				 * The device is out of space.
				 * The store could not be migrated to the current model version.
				 Check the error message to determine what the actual problem was.
				 */
				Self.logger.error("Failed to load stores: \(error, privacy: .public), \(error.userInfo, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			}

			storeDescription.shouldMigrateStoreAutomatically = true
			storeDescription.shouldInferMappingModelAutomatically = true
		}

		container.viewContext.automaticallyMergesChangesFromParent = true
		container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

		backgroundContext = container.newBackgroundContext()
		backgroundContext.automaticallyMergesChangesFromParent = true
		backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
	}

	func reset() {
		Self.logger.warning("Resetting CoreData! [\(String._debugInfo(), privacy: .public)]")

		let entities = container.managedObjectModel.entities
		for entity in entities {
			guard let entityName = entity.name else { continue }
			let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
			let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
			do {
				try container.viewContext.execute(deleteRequest)
			} catch {
				Self.logger.error("Failed to remove entity \"\(entityName, privacy: .public)\": \(error, privacy: .public) [\(String._debugInfo(), privacy: .public)]")
			}
		}
	}
}
