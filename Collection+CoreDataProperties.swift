//
//  Collection+CoreDataProperties.swift
//  iOS-AntiquesIdentifier
//
//  Created by Smit Savaliya on 29/10/25.
//
//

public import Foundation
public import CoreData


public typealias CollectionCoreDataPropertiesSet = NSSet

extension Collection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Collection> {
        return NSFetchRequest<Collection>(entityName: "Collection")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var antique: NSSet?

}

// MARK: Generated accessors for antique
extension Collection {

    @objc(addAntiqueObject:)
    @NSManaged public func addToAntique(_ value: Antique)

    @objc(removeAntiqueObject:)
    @NSManaged public func removeFromAntique(_ value: Antique)

    @objc(addAntique:)
    @NSManaged public func addToAntique(_ values: NSSet)

    @objc(removeAntique:)
    @NSManaged public func removeFromAntique(_ values: NSSet)

}

extension Collection : Identifiable {

}
