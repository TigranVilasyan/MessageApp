//
//  CDMessage+CoreDataProperties.swift
//  MessageApp
//
//  Created by NokNokMac on 04.08.25.
//
//

import Foundation
import CoreData


extension CDMessage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDMessage> {
        return NSFetchRequest<CDMessage>(entityName: "CDMessage")
    }

    @NSManaged public var id: String
    @NSManaged public var text: String?
    @NSManaged public var isSender: Bool
    @NSManaged public var author: String?
    @NSManaged public var timestamp: Date

}

extension CDMessage : Identifiable {

}
