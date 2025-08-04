//
//  MessageEntity.swift
//  MessageApp
//
//  Created by NokNokMac on 01.08.25.
//


import Foundation

struct MessageEntity: Hashable, Codable {
    let id: String
    let text: String
    let isSender: Bool
    let timestamp: String
    let author: String
//    let imageBase64: String?
    
    static func == (lhs: MessageEntity, rhs: MessageEntity) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
