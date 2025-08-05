//
//  PersistenceController.swift
//  MessageApp
//


import CoreData

/// Manages the Core Data stack for the application, including the persistent container and configuration.
struct PersistenceController {
    /// Shared singleton instance for global access.
    static let shared = PersistenceController()

    /// The Core Data persistent container.
    let container: NSPersistentContainer

    /// Initializes the persistence controller.
    /// - Parameter inMemory: If true, uses an in-memory store (useful for testing).
    init(inMemory: Bool = false) {
        // Initialize the persistent container with the Core Data model name.
        container = NSPersistentContainer(name: "MessageApp") // Replace with your .xcdatamodeld name
        // Optionally configure for an in-memory store if required (e.g., unit tests).
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        // Load the persistent stores and handle errors.
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data store failed \(error)")
            }
        }
        // Set merge policy to resolve conflicts by keeping local changes.
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        // Automatically merge changes from parent contexts.
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
