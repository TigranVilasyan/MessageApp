//
//  MessageRepository.swift
//  MessageApp
//
//  Created by NokNokMac on 04.08.25.
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

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }

    func fetchMessages(limit: Int, offset: Int) throws -> [MessageEntity] {
        let fetchRequest: NSFetchRequest<CDMessage> = CDMessage.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        fetchRequest.fetchLimit = limit
        fetchRequest.fetchOffset = offset

        let cdMessages = try context.fetch(fetchRequest)
        return cdMessages.reversed().map {
            MessageEntity(
                id: $0.id,
                text: $0.text ?? "",
                isSender: $0.isSender,
                timestamp: ISO8601DateFormatter().string(from: $0.timestamp),
                author: $0.author ?? ""
            )
        }
    }

    func saveMessages(_ messages: [MessageEntity]) throws {
        messages.forEach { msg in
            let cdMessage = CDMessage(context: context)
            cdMessage.id = msg.id
            cdMessage.text = msg.text
            cdMessage.isSender = msg.isSender
            cdMessage.timestamp = ISO8601DateFormatter().date(from: msg.timestamp)!
            cdMessage.author = msg.author
        }
        try context.save()
    }

    func saveMessage(_ message: MessageEntity) throws {
        let cdMessage = CDMessage(context: context)
        cdMessage.id = message.id
        cdMessage.text = message.text
        cdMessage.isSender = message.isSender
        cdMessage.timestamp = ISO8601DateFormatter().date(from: message.timestamp)!
        cdMessage.author = message.author
        try context.save()
    }
    
    func fetchExistingIDs() throws -> Set<String> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CDMessage.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = ["id"]

        let results = try context.fetch(fetchRequest) as? [[String: Any]]
        let ids = results?.compactMap { $0["id"] as? String } ?? []
        return Set(ids)
    }

}
