//
//  CoreData.swift
//  Harbour
//
//  Created by royal on 08/02/2022.
//

import Foundation
import CoreData
import os.log

struct Persistence {
	public static let shared = Persistence()

	public let container: NSPersistentContainer
	public let backgroundContext: NSManagedObjectContext

	private let logger: Logger = Logger(subsystem: Bundle.main.mainBundleIdentifier, category: "Persistence")

	init() {
		let groupURL: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.\(Bundle.main.mainBundleIdentifier)")!.appendingPathComponent("Harbour.sqlite")
		let modelURL = Bundle.main.url(forResource: "Harbour", withExtension: "momd")
		let model = NSManagedObjectModel(contentsOf: modelURL!)

		container = NSPersistentContainer(name: "Harbour", managedObjectModel: model!)

		let description: NSPersistentStoreDescription = NSPersistentStoreDescription()
		description.url = groupURL
		description.shouldMigrateStoreAutomatically = true
		description.shouldInferMappingModelAutomatically = true

		container.persistentStoreDescriptions = [description]

		container.loadPersistentStores(completionHandler: { [weak container, logger] (storeDescription, error) in
			if let error = error {
				logger.error("\(String(describing: error))")
				try? container?.persistentStoreCoordinator.destroyPersistentStore(at: groupURL, type: NSPersistentStore.StoreType.sqlite)
			}
		})

		container.persistentStoreCoordinator.perform { [weak container] in
			container?.viewContext.automaticallyMergesChangesFromParent = true
			container?.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
		}

		backgroundContext = container.newBackgroundContext()
	}

	/// Removes persistent store, removing all stored data.
	public func reset() {
		guard let url = container.persistentStoreDescriptions.first?.url else { return }

		do {
			logger.info("Resetting")
			try container.persistentStoreCoordinator.destroyPersistentStore(at: url, type: NSPersistentStore.StoreType.sqlite)
		} catch {
			logger.error("\(String(describing: error))")
		}
	}
}
