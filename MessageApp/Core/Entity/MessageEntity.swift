//
//  MessageEntity.swift
//  MessageApp
//

import Foundation

/// Model representing a chat message within the messaging application.

/// Encapsulates all properties related to a chat message.
struct MessageEntity: Hashable, Codable {
    let id: String
    let text: String
    
    /// Indicates if the message was sent by the current user.
    let isSender: Bool
    
    /// Timestamp when the message was sent, formatted as a String.
    let timestamp: String
    
    let author: String
    
    /// Optional Base64-encoded image data associated with the message.
    // let imageBase64: String?
    
    /// Equality check based on unique message identifier.
    /// Ensures each message is uniquely identified by its `id`.
    static func == (lhs: MessageEntity, rhs: MessageEntity) -> Bool {
        return lhs.id == rhs.id
    }

    /// Hash the message based on its unique `id`.
    /// Supports usage in hashed collections like sets or dictionary keys.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
