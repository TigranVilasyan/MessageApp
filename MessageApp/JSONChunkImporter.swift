//
//  JSONChunkImporter.swift
//  MessageApp
//
//  Created by NokNokMac on 04.08.25.
//

import CoreData
import Foundation

class JSONChunkImporter {
    private let chunkSize: Int
    private let filename: String
    private let userDefaultsKey = "jsonChunkImporterOffset"
    private let messageRepository: MessageRepositoryProtocol
    
    init(filename: String, chunkSize: Int = 20, repository: MessageRepositoryProtocol) {
        self.filename = filename
        self.chunkSize = chunkSize
        self.messageRepository = repository
    }
    
    private func loadJSON() -> [[String: Any]]? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("JSON file not found")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
            return jsonArray
        } catch {
            print("Failed to load or parse JSON: \(error)")
            return nil
        }
    }
    
    func importNextChunk() {
        guard let jsonArray = loadJSON() else { return }

        let currentOffset = UserDefaults.standard.integer(forKey: userDefaultsKey)
        guard currentOffset < jsonArray.count else {
            print("All data imported")
            return
        }

        let endIndex = min(currentOffset + chunkSize, jsonArray.count)
        let chunk = jsonArray[currentOffset..<endIndex]

        var messagesToSave = Set<MessageEntity>()

        for jsonItem in chunk {
            guard
                let id = jsonItem["id"] as? String,
                let text = jsonItem["text"] as? String,
                let isSender = jsonItem["isSender"] as? Bool,
                let timestamp = jsonItem["timestamp"] as? String,
                let author = jsonItem["author"] as? String
            else {
                continue
            }

            messagesToSave.insert(MessageEntity(
                id: id,
                text: text,
                isSender: isSender,
                timestamp: timestamp,
                author: author
            ))
        }

        do {
            let existingIDs = try messageRepository.fetchExistingIDs()
            
            // Subtract existing messages based on ID
            let uniqueMessages = messagesToSave.filter { !existingIDs.contains($0.id) }

            try messageRepository.saveMessages(Array(uniqueMessages))

            UserDefaults.standard.set(endIndex, forKey: userDefaultsKey)
            print("Saved \(uniqueMessages.count) new messages from chunk \(currentOffset)–\(endIndex)")
        } catch {
            print("Failed during import: \(error)")
        }
    }

    
    func resetImport() {
        UserDefaults.standard.set(0, forKey: userDefaultsKey)
    }
}
