//
//  Antique+CoreDataProperties.swift
//  iOS-AntiquesIdentifier
//
//  Created by Smit Savaliya on 29/10/25.
//
//

public import Foundation
public import CoreData


public typealias AntiqueCoreDataPropertiesSet = NSSet

extension Antique {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Antique> {
        return NSFetchRequest<Antique>(entityName: "Antique")
    }

    @NSManaged public var antiqueimg: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var desc: String?
    @NSManaged public var eraPeriod: String?
    @NSManaged public var estimatedValueMax: Double
    @NSManaged public var estimatedValueMin: Double
    @NSManaged public var historicalContext: String?
    @NSManaged public var id: UUID?
    @NSManaged public var isDefault: Bool
    @NSManaged public var makers: String?
    @NSManaged public var name: String?
    @NSManaged public var origin: String?
    @NSManaged public var category: String?
    @NSManaged public var collecion: NSSet?

}

// MARK: Generated accessors for collecion
extension Antique {

    @objc(addCollecionObject:)
    @NSManaged public func addToCollecion(_ value: Collection)

    @objc(removeCollecionObject:)
    @NSManaged public func removeFromCollecion(_ value: Collection)

    @objc(addCollecion:)
    @NSManaged public func addToCollecion(_ values: NSSet)

    @objc(removeCollecion:)
    @NSManaged public func removeFromCollecion(_ values: NSSet)

}

extension Antique : Identifiable {

}
