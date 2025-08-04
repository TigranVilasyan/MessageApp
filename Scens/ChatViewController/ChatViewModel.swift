//
//  ChatViewModel.swift
//  MessageApp
//
//  Created by NokNokMac on 04.08.25.
//

import Foundation
import CoreData
import Combine


protocol ChatViewModelInput: AnyObject {
    func viewDidLoad()
    func numberOfMessages() -> Int
    func message(at index: Int) -> MessageEntity
}


protocol ChatViewModelOutput: AnyObject {
    func loadMessages()
    func addMessage(text: String, isSender: Bool, author: String)
    func loadNextPage()
    var messagesPublisher: AnyPublisher<[MessageEntity], Never> { get }
}

protocol ChatViewModelType: AnyObject {
    var inputs: ChatViewModelInput { get }
    var outputs: ChatViewModelOutput { get }
}

final class ChatViewModel: ObservableObject,
                           ChatViewModelType,
                           ChatViewModelOutput,
                           ChatViewModelInput {
    
    var inputs: ChatViewModelInput { return self }
    
    var outputs: ChatViewModelOutput { return self }
    
    @Published private(set) var messages: [MessageEntity] = []
    
    var messagesPublisher: AnyPublisher<[MessageEntity], Never> {
        return $messages.eraseToAnyPublisher()
    }
    private let repository: MessageRepositoryProtocol
    private let importer: JSONChunkImporter
    
    private var pageSize = 20
    private var currentOffset = 0
    private var isLoading = false

    init(repository: MessageRepositoryProtocol = MessageRepository(),
         importer: JSONChunkImporter? = nil) {
        self.repository = repository
        if let imp = importer {
            self.importer = imp
        } else {
            self.importer = JSONChunkImporter(filename: "messages", chunkSize: 20, repository: repository)
        }
    }
    
    func viewDidLoad() {
        
    }
    

    func loadMessages() {
        messages = []
        currentOffset = 0
        importer.resetImport()  // reset import progress
        loadNextPage()
    }

    func loadNextPage() {
        guard !isLoading else { return }
        isLoading = true

        // Step 1: Import next chunk from JSON into Core Data
        importer.importNextChunk()

        // Step 2: Fetch next chunk from Core Data and append to messages
        do {
            let newMessages = try repository.fetchMessages(limit: pageSize, offset: currentOffset)
            currentOffset += newMessages.count
            
            DispatchQueue.main.async {
                // Insert new messages at the beginning for chat timeline ascending order
                self.messages.insert(contentsOf: newMessages, at: 0)
                self.isLoading = false
            }
        } catch {
            print("Error loading messages: \(error)")
            isLoading = false
        }
    }

    func addMessage(text: String, isSender: Bool, author: String) {
        let message = MessageEntity(
            id: UUID().uuidString, text: text,
            isSender: isSender,
            timestamp: ISO8601DateFormatter().string(from: Date()),
            author: author
        )

        do {
            try repository.saveMessage(message)
            DispatchQueue.main.async {
                self.messages.append(message)
            }
        } catch {
            print("Failed to save new message: \(error)")
        }
    }

    func numberOfMessages() -> Int {
        messages.count
    }

    func message(at index: Int) -> MessageEntity {
        messages[index]
    }
}
