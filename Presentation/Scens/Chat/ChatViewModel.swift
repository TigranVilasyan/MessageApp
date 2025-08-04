//
//  ChatViewModel.swift
//  MessageApp
//
//  Created by NokNokMac on 04.08.25.
//

import Foundation
import CoreData
import Combine

/// Protocol defining input methods related to UI events and data requests.
protocol ChatViewModelInput: AnyObject {
    /// Called when the view is loaded.
    func viewDidLoad()
    /// Returns the current number of loaded messages.
    func numberOfMessages() -> Int
    /// Returns the message at a given index.
    func message(at index: Int) -> MessageEntity
}

/// Protocol defining output methods for data loading and publishing updates.
protocol ChatViewModelOutput: AnyObject {
    /// Initiates loading of messages from the source.
    func loadMessages()
    /// Adds a new message with given text, sender info, and author.
    func addMessage(text: String, isSender: Bool, author: String)
    /// Loads the next page of messages for pagination.
    func loadNextPage()
    /// Publisher that emits updated arrays of messages.
    var messagesPublisher: AnyPublisher<[MessageEntity], Never> { get }
}

/// Protocol combining input and output interfaces for the view model.
protocol ChatViewModelType: AnyObject {
    var inputs: ChatViewModelInput { get }
    var outputs: ChatViewModelOutput { get }
}

/// ViewModel managing message data loading, pagination, and user interactions.
/// It handles importing messages from JSON chunks into Core Data and exposes
/// messages to the UI via Combine publishers.
final class ChatViewModel: ObservableObject,
                           ChatViewModelType,
                           ChatViewModelOutput,
                           ChatViewModelInput {
    
    // MARK: - Protocol Conformance
    
    var inputs: ChatViewModelInput { return self }
    var outputs: ChatViewModelOutput { return self }
    
    // MARK: - Published Properties
    
    /// Published array of messages that the UI observes.
    @Published private(set) var messages: [MessageEntity] = []
    
    /// Publisher exposing message updates as a stream.
    var messagesPublisher: AnyPublisher<[MessageEntity], Never> {
        return $messages.eraseToAnyPublisher()
    }
    
    // MARK: - Private Properties
    
    /// The data repository for fetching and saving messages.
    private let repository: MessageRepositoryProtocol
    /// Responsible for importing JSON message data in chunks.
    private let importer: JSONChunkImporter
    
    /// Number of messages to load per page.
    private var pageSize = 20
    /// Current offset used for pagination in the data repository.
    private var currentOffset = 0
    /// Flag indicating if a data load operation is in progress.
    private var isLoading = false

    // MARK: - Initializer
    
    init(repository: MessageRepositoryProtocol = MessageRepository(),
         importer: JSONChunkImporter? = nil) {
        self.repository = repository
        if let imp = importer {
            self.importer = imp
        } else {
            self.importer = JSONChunkImporter(filename: "messages", chunkSize: 20, repository: repository)
        }
    }
    
    // MARK: - Input Methods
    
    func viewDidLoad() {
        // Currently no setup needed on view load.
    }
    
    func numberOfMessages() -> Int {
        // Return the count of currently loaded messages.
        messages.count
    }

    func message(at index: Int) -> MessageEntity {
        // Return the message at the specified index.
        messages[index]
    }
    
    // MARK: - Output Methods
    
    func loadMessages() {
        // Reset message list and pagination state.
        messages = []
        currentOffset = 0
        importer.resetImport()  // Reset import progress to start fresh.
        loadNextPage()          // Load the first page of messages.
    }

    func loadNextPage() {
        // Prevent overlapping load operations.
        guard !isLoading else { return }
        isLoading = true

        // Step 1: Import next chunk of messages from JSON into Core Data.
        importer.importNextChunk()

        // Step 2: Fetch messages from Core Data with pagination.
        do {
            let newMessages = try repository.fetchMessages(limit: pageSize, offset: currentOffset)
            currentOffset += newMessages.count
            
            DispatchQueue.main.async {
                // Insert new messages at the beginning to maintain ascending order timeline.
                self.messages.insert(contentsOf: newMessages, at: 0)
                self.isLoading = false
            }
        } catch {
            print("Error loading messages: \(error)")
            isLoading = false
        }
    }

    func addMessage(text: String, isSender: Bool, author: String) {
        // Create a new message entity with current timestamp.
        let message = MessageEntity(
            id: UUID().uuidString, text: text,
            isSender: isSender,
            timestamp: ISO8601DateFormatter().string(from: Date()),
            author: author
        )

        do {
            // Save the new message to the repository.
            try repository.saveMessage(message)
            DispatchQueue.main.async {
                // Append the new message to the messages array.
                self.messages.append(message)
            }
        } catch {
            print("Failed to save new message: \(error)")
        }
    }
}
