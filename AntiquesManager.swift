//
//  AntiqueCollectionManager.swift
//  iOS-AntiquesIdentifier
//
//  Created by Smit Savaliya on 27/10/25.
//

import CoreData
import Foundation

struct AntiqueManager {
    
    private static let context = CoreDataHelper.shared.context
    
    // MARK: - 🧱 ANTIQUE QUERIES
    /// Add new Antique
    static func addAntique(from model: AntiqueModel , id:UUID? = nil) -> Antique {
        let antique = Antique(context: context)
        antique.id = id ?? UUID()
        antique.name = model.name
        antique.desc = model.description
        antique.origin = model.origin
        antique.eraPeriod = model.eraPeriod
        antique.historicalContext = model.historicalContext
        antique.estimatedValueMin = model.estimatedValueUSD.min
        antique.estimatedValueMax = model.estimatedValueUSD.max
        antique.makers = model.makers
        antique.createdAt = Date()
        antique.antiqueimg =  model.antiqueImg
        antique.isDefault = model.isDefault ?? false
        antique.category  = model.category
        CoreDataHelper.shared.saveContext()
        print("✅ Antique '\(antique.name ?? "") \(antique.id) added successfully")
        return antique
    }
    
    /// Delete Antique by ID
    static func deleteAntique(by id: UUID) {
        let request: NSFetchRequest<Antique> = Antique.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            if let antique = try context.fetch(request).first {
                context.delete(antique)
                CoreDataHelper.shared.saveContext()
                print("🗑️ Deleted Antique \(antique.name ?? "")")
            } else {
                print("⚠️ Antique not found")
            }
        } catch {
            print("❌ Failed to delete Antique: \(error.localizedDescription)")
        }
    }
    
    // MARK: - FETCH ALL
        static func fetchAllAntiques() -> [AntiqueModel] {
            let request: NSFetchRequest<Antique> = Antique.fetchRequest()
        request.predicate = NSPredicate(format: "isDefault == %@", NSNumber(value: false))
            
            do {
                let results = try context.fetch(request)
                return results.map { antique in
                    return AntiqueModel(
                        id: antique.id , name: antique.name ?? "-", antiqueImg: antique.antiqueimg,
                        description: antique.desc ?? "-",
                        origin: antique.origin ?? "-",
                        eraPeriod: antique.eraPeriod ?? "-",
                        historicalContext: antique.historicalContext ?? "-",
                        estimatedValueUSD: .init(min: antique.estimatedValueMin, max: antique.estimatedValueMax),
                        condition: "-",
                        rarityScore: 0,
                        makers: antique.makers ?? "-",
                        materials:  "-",
                        dimension: "-",
                        craftsmanshipStyle: "-", visualMatches: nil,
                        isDefault: antique.isDefault, category: antique.category
                    )
                }
            } catch {
                print("❌ Failed to fetch antiques: \(error.localizedDescription)")
                return []
                
            }
        }
    
    // MARK: - FETCH BY ID
       static func getAntique(by id: UUID) -> AntiqueModel? {
           let request: NSFetchRequest<Antique> = Antique.fetchRequest()
           request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
           request.fetchLimit = 1
           
           do {
               guard let antique = try context.fetch(request).first else { return nil }
               
               return AntiqueModel(
                id: antique.id , name: antique.name ?? "-", antiqueImg: antique.antiqueimg,
                   description: antique.desc ?? "-",
                   origin: antique.origin ?? "-",
                   eraPeriod: antique.eraPeriod ?? "-",
                   historicalContext: antique.historicalContext ?? "-",
                   estimatedValueUSD: .init(min: antique.estimatedValueMin, max: antique.estimatedValueMax),
                   condition:  "-",
                   rarityScore: 0,
                   makers: antique.makers ?? "-",
                   materials:  "-",
                   dimension:  "-",
                   craftsmanshipStyle: "-",
                visualMatches: nil, isDefault: antique.isDefault, category: antique.category
               )
           } catch {
               print("❌ Failed to fetch antique by ID: \(error.localizedDescription)")
               return nil
           }
       }
    
}
