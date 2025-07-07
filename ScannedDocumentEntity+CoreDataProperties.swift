//
//  ScannedDocumentEntity+CoreDataProperties.swift
//  ScanMate
//
//  Created by Maruf on 26/6/25.
//
//

import Foundation
import CoreData


extension ScannedDocumentEntityNew {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ScannedDocumentEntity> {
        return NSFetchRequest<ScannedDocumentEntity>(
            entityName: "ScannedDocumentEntity"
        )
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var filePath: String?
    @NSManaged public var thumbnail: Data?

}

extension ScannedDocumentEntity : Identifiable {

}
