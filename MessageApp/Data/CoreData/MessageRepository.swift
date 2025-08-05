//
//  MessageRepository.swift
//  MessageApp
//


import CoreData
import Foundation

protocol MessageRepositoryProtocol {
    func fetchMessages(limit: Int, offset: Int) throws -> [MessageEntity]
    func saveMessages(_ messages: [MessageEntity]) throws
    func saveMessage(_ message: MessageEntity) throws
    func fetchExistingIDs() throws -> Set<String>
}

final class MessageRepository: MessageRepositoryProtocol {

    // Core Data context used for database operations
    private let context: NSManagedObjectContext

    // Default initializer using the shared Core Data stack
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    /// Fetches paginated messages from Core Data, ordered by timestamp (newest first)
    func fetchMessages(limit: Int, offset: Int) throws -> [MessageEntity] {
        let fetchRequest: NSFetchRequest<CDMessage> = CDMessage.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        fetchRequest.fetchLimit = limit
        fetchRequest.fetchOffset = offset

        let cdMessages = try context.fetch(fetchRequest)

        // Reverse to return oldest to newest (e.g., for displaying in chat UI)
        return cdMessages.reversed().map {
            MessageEntity(
                id: $0.id!,
                text: $0.text ?? "",
                isSender: $0.isSender,
                timestamp: ISO8601DateFormatter().string(from: $0.timestamp!),
                author: $0.author ?? ""
            )
        }
    }

    /// Saves an array of messages to Core Data
    func saveMessages(_ messages: [MessageEntity]) throws {
        messages.forEach { msg in
            let cdMessage = CDMessage(context: context)
            cdMessage.id = msg.id
            cdMessage.text = msg.text
            cdMessage.isSender = msg.isSender
            cdMessage.timestamp = ISO8601DateFormatter().date(from: msg.timestamp)!
            cdMessage.author = msg.author
        }

        // Save the context after batch insert
        try context.save()
    }

    /// Saves a single message to Core Data
    func saveMessage(_ message: MessageEntity) throws {
        let cdMessage = CDMessage(context: context)
        cdMessage.id = message.id
        cdMessage.text = message.text
        cdMessage.isSender = message.isSender
        cdMessage.timestamp = ISO8601DateFormatter().date(from: message.timestamp)!
        cdMessage.author = message.author

        try context.save()
    }

    /// Fetches all existing message IDs from Core Data to prevent duplicates
    func fetchExistingIDs() throws -> Set<String> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CDMessage.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = ["id"]

        let results = try context.fetch(fetchRequest) as? [[String: Any]]
        let ids = results?.compactMap { $0["id"] as? String } ?? []
        return Set(ids)
    }
}
