//
//  CollectionManager.swift
//  iOS-AntiquesIdentifier
//
//  Created by Smit Savaliya on 27/10/25.
//

import Foundation
import CoreData
import UIKit

struct CollectionManager {
    
    private static let context = CoreDataHelper.shared.context
    
    // MARK: - 1️⃣ Create New Empty Collection
    /// Create a new Collection and add a single Antique (from AntiqueModel)
        static func createCollectionWithAntique(name: String, model: AntiqueModel) {
            let context = CoreDataHelper.shared.context
            
            // 1️⃣ Create Antique from model
            let antique = Antique(context: context)
            antique.id = UUID()
            antique.name = model.name
            antique.desc = model.description
            antique.origin = model.origin
            antique.eraPeriod = model.eraPeriod
            antique.historicalContext = model.historicalContext
            antique.estimatedValueMin = model.estimatedValueUSD.min
            antique.estimatedValueMax = model.estimatedValueUSD.max
            antique.makers = model.makers
            antique.createdAt = Date()
            antique.antiqueimg = model.antiqueImg
            antique.isDefault = model.isDefault ?? false
            
            // 2️⃣ Create Collection
            let collection = Collection(context: context)
            collection.id = UUID()
            collection.name = name
            collection.createdAt = Date()
            
            // 3️⃣ Add relationship
            collection.addToAntique(antique)
            
            // 4️⃣ Save context
            CoreDataHelper.shared.saveContext()
            
            print("✅ Created Collection '\(name)' and added Antique '\(antique.name ?? "")'")
        }
        // MARK: - 1️⃣ (b) Create Collection With Antiques (Model-wise)
    /// Create a new Collection and attach an existing Antique (using its UUID)
       static func createCollectionWithExistingAntique(name: String, antiqueId: UUID) {
           // 1️⃣ Fetch the existing antique by UUID
           let request: NSFetchRequest<Antique> = Antique.fetchRequest()
           request.predicate = NSPredicate(format: "id == %@", antiqueId as CVarArg)
           request.fetchLimit = 1
           
           do {
               if let antique = try context.fetch(request).first {
                   // 2️⃣ Create new collection
                   let collection = Collection(context: context)
                   collection.id = UUID()
                   collection.name = name
                   collection.createdAt = Date()
                   
                   // 3️⃣ Link existing antique
                   collection.addToAntique(antique)
                   
                   // 4️⃣ Save
                   CoreDataHelper.shared.saveContext()
                   print("✅ Created Collection '\(name)' with existing Antique '\(antique.name ?? "")'")
               } else {
                   print("❌ No Antique found with id \(antiqueId)")
               }
           } catch {
               print("❌ Error fetching Antique: \(error.localizedDescription)")
           }
       }
    
    // MARK: - 2️⃣ Create Collection With Existing Antique (Using Relationship)
       static func createCollectionWithAntique(name: String, antique: Antique) {
           let collection = Collection(context: context)
           collection.id = UUID()
           collection.name = name
           collection.createdAt = Date()
           
           // Link existing Antique
           collection.addToAntique(antique)
           
           // Save context
           CoreDataHelper.shared.saveContext()
           print("✅ Collection '\(name)' created with existing Antique '\(antique.name ?? "")'")
       }

    
    // MARK: 1️⃣ Create Empty Collection
        static func createCollection(name: String){
            let collection = Collection(context: context)
            collection.id = UUID()
            collection.name = name
            collection.createdAt = Date()
            CoreDataHelper.shared.saveContext()
            print("✅ Created empty Collection '\(name)'")
        }
    
//    / MARK: 4️⃣ Check if Antique Exists (by name or id)
        static func isAntiqueExists(inCollectionId collectionId: UUID, model: AntiqueModel) -> Bool {
            let request: NSFetchRequest<Collection> = Collection.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", collectionId as CVarArg)
            do {
                if let collection = try context.fetch(request).first,
                   let antiques = collection.antique as? Set<Antique> {
                    return antiques.contains { $0.name == model.name }
                }
            } catch {
                print("❌ Failed to check antique existence: \(error.localizedDescription)")
            }
            return false
        }
    
    // MARK: - Fetch Specific Collection
       static func fetchCollection(by id: UUID) -> Collection? {
           let context = CoreDataHelper.shared.context
           let request: NSFetchRequest<Collection> = Collection.fetchRequest()
           request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
           return try? context.fetch(request).first
       }
    
    // MARK: 5️⃣ Fetch All Antiques (as models) in Specific Collection
     static func fetchAntiques(inCollectionId id: UUID) -> [AntiqueModel] {
         let request: NSFetchRequest<Collection> = Collection.fetchRequest()
         request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
         do {
             if let collection = try context.fetch(request).first,
                let antiques = collection.antique as? Set<Antique> {
                 
                 // Convert to array and sort — latest added (by createdAt) first, fallback to id if needed
                           let sortedAntiques = antiques.sorted {
                               ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast)
                           }
                 
                 return sortedAntiques.map { antique in
                     AntiqueModel(
                        id:antique.id ?? UUID(),
                        name: antique.name ?? "", antiqueImg: antique.antiqueimg ?? "",
                         description: antique.desc ?? "",
                         origin: antique.origin ?? "",
                         eraPeriod: antique.eraPeriod ?? "",
                         historicalContext: antique.historicalContext ?? "",
                         estimatedValueUSD: .init(min: antique.estimatedValueMin, max: antique.estimatedValueMax),
                         condition: "-",
                         rarityScore: 0,
                         makers: antique.makers ?? "",
                         materials: "-",
                         dimension: "-",
                         craftsmanshipStyle: "-",
                         visualMatches: [],
                        isDefault: antique.isDefault, category: antique.category
                     )
                 }
             }
         } catch {
             print("❌ Error fetching antiques: \(error.localizedDescription)")
         }
         return []
     }
     
     // MARK: 6️⃣ Remove Specific Antique from Collection
    static func removeAntiqueRelation(fromCollectionId collectionId: UUID, antiqueId: UUID) {
        let collectionRequest: NSFetchRequest<Collection> = Collection.fetchRequest()
        collectionRequest.predicate = NSPredicate(format: "id == %@", collectionId as CVarArg)
        
        do {
            if let collection = try context.fetch(collectionRequest).first,
               let antiques = collection.antique as? Set<Antique>,
               let targetAntique = antiques.first(where: { $0.id == antiqueId }) {
                
                // Remove only relation
                collection.removeFromAntique(targetAntique)
                CoreDataHelper.shared.saveContext()
                
                print("🔗 Removed relation of Antique '\(targetAntique.name ?? "")' from Collection '\(collection.name ?? "")'.")
            } else {
                print("⚠️ Antique or Collection not found.")
            }
        } catch {
            print("❌ Error removing relation: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 3️⃣ (b) Delete Specific Antique from a Specific Collection
    static func deleteAntiqueCompletely(fromCollectionId collectionId: UUID, antiqueId: UUID) {
        let collectionRequest: NSFetchRequest<Collection> = Collection.fetchRequest()
        collectionRequest.predicate = NSPredicate(format: "id == %@", collectionId as CVarArg)
        
        do {
            if let collection = try context.fetch(collectionRequest).first,
               let antiques = collection.antique as? Set<Antique>,
               let targetAntique = antiques.first(where: { $0.id == antiqueId }) {
                
                // Remove relationship first
                collection.removeFromAntique(targetAntique)
                // Then delete from Core Data
                context.delete(targetAntique)
                
                CoreDataHelper.shared.saveContext()
                print("🗑️ Deleted Antique '\(targetAntique.name ?? "")' from Collection and Core Data.")
            } else {
                print("⚠️ Antique or Collection not found.")
            }
        } catch {
            print("❌ Error deleting antique: \(error.localizedDescription)")
        }
    }
    
    // MARK: 3️⃣ Add Antique (from model) to Specific Collection
        static func addAntiqueToCollection(collectionId: UUID, model: AntiqueModel) {
            let request: NSFetchRequest<Collection> = Collection.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", collectionId as CVarArg)
            do {
                if let collection = try context.fetch(request).first {
                    let antique = AntiqueManager.addAntique(from: model)
                    collection.addToAntique(antique)
                    CoreDataHelper.shared.saveContext()
                    print("✅ Added Antique '\(antique.name ?? "")' to Collection '\(collection.name ?? "")'")
                } else {
                    print("⚠️ Collection not found for ID: \(collectionId)")
                }
            } catch {
                print("❌ Failed to add antique: \(error.localizedDescription)")
            }
        }
    
    /// Add an existing Antique (by ID) to a specific Collection
     static func addExistingAntiqueToCollection(collectionId: UUID, antiqueId: UUID) {
         let collectionRequest: NSFetchRequest<Collection> = Collection.fetchRequest()
         let antiqueRequest: NSFetchRequest<Antique> = Antique.fetchRequest()
         
         collectionRequest.predicate = NSPredicate(format: "id == %@", collectionId as CVarArg)
         antiqueRequest.predicate = NSPredicate(format: "id == %@", antiqueId as CVarArg)
         
         do {
             guard let collection = try context.fetch(collectionRequest).first else {
                 print("⚠️ Collection not found for ID: \(collectionId)")
                 return
             }
             
             guard let antique = try context.fetch(antiqueRequest).first else {
                 print("⚠️ Antique not found for ID: \(antiqueId)")
                 return
             }
             
             // Add relationship
             collection.addToAntique(antique)
             CoreDataHelper.shared.saveContext()
             
             print("✅ Added existing Antique '\(antique.name ?? "")' to Collection '\(collection.name ?? "")'")
             
         } catch {
             print("❌ Failed to add existing Antique to Collection: \(error.localizedDescription)")
         }
     }
    
    // MARK: - 5️⃣ Delete Whole Collection (by UUID)
    static func deleteCollection(by collectionId: UUID) {
        let request: NSFetchRequest<Collection> = Collection.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", collectionId as CVarArg)
        
        do {
            if let collection = try context.fetch(request).first {
                context.delete(collection)
                CoreDataHelper.shared.saveContext()
                print("🗑️ Deleted Collection '\(collection.name ?? "")'")
            } else {
                print("⚠️ Collection not found")
            }
        } catch {
            print("❌ Failed to delete Collection: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 6️⃣ Rename Specific Collection
       static func renameCollection(collectionId: UUID, newName: String) {
           let request: NSFetchRequest<Collection> = Collection.fetchRequest()
           request.predicate = NSPredicate(format: "id == %@", collectionId as CVarArg)
           do {
               if let collection = try context.fetch(request).first {
                   collection.name = newName
                   CoreDataHelper.shared.saveContext()
                   print("✏️ Renamed Collection to '\(newName)'")
               }
           } catch {
               print("❌ Failed to rename collection: \(error.localizedDescription)")
           }
       }

    // MARK: - Fetch All Collections (Model Wise)
    static func fetchAllCollections() -> [AntiqueCollectionModel] {
        let request: NSFetchRequest<Collection> = Collection.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let collections = try context.fetch(request)
            
            return collections.map { collection in
                
                // Sort antiques so newest ones appear first
                let sortedAntiques: [Antique] = (collection.antique?.allObjects as? [Antique])?.sorted {
                    ($0.createdAt ?? Date.distantPast) > ($1.createdAt ?? Date.distantPast)
                } ?? []
                
                // Convert to [AntiqueModel]
                let antiques: [AntiqueModel] = sortedAntiques.map { antique in
                    AntiqueModel(
                        id: antique.id ?? UUID(),
                        name: antique.name ?? "",
                        antiqueImg: antique.antiqueimg,
                        description: antique.desc ?? "",
                        origin: antique.origin ?? "",
                        eraPeriod: antique.eraPeriod ?? "",
                        historicalContext: antique.historicalContext ?? "",
                        estimatedValueUSD: AntiqueModel.EstimatedValue(
                            min: antique.estimatedValueMin,
                            max: antique.estimatedValueMax
                        ),
                        condition:  "-",
                        rarityScore: 0,
                        makers: antique.makers ?? "",
                        materials:  "-",
                        dimension:  "-",
                        craftsmanshipStyle:  "-",
                        visualMatches: nil,
                        isDefault: antique.isDefault, category: antique.category
                    )
                }
                
                // Return final model
                return AntiqueCollectionModel(
                    name: collection.name ?? "",
                    id: collection.id ?? UUID(),
                    createdAt: collection.createdAt ?? Date(),
                    antiqueItems: antiques
                )
            }
            
        } catch {
            print("❌ Error fetching collections: \(error.localizedDescription)")
            return []
        }
    }

    
    static func fetchCollectionsNotContainingAntique(byName antiqueName: String) -> [AntiqueCollectionModel] {
           let collectionRequest: NSFetchRequest<Collection> = Collection.fetchRequest()
        collectionRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
           do {
               // 1️⃣ Fetch all collections
               let allCollections = try context.fetch(collectionRequest)
               
               // 2️⃣ Filter out collections that already have this antique name
               let filteredCollections = allCollections.filter { collection in
                   guard let antiques = collection.antique as? Set<Antique> else { return true }
                   return !antiques.contains(where: { ($0.name ?? "").lowercased() == antiqueName.lowercased() })
               }
               
               // 3️⃣ Transform to Model
               let models: [AntiqueCollectionModel] = filteredCollections.map { collection in
                   let antiques: [AntiqueModel] = (collection.antique as? Set<Antique>)?.compactMap { antique in
                       AntiqueModel(
                           id: antique.id,
                           name: antique.name ?? "-",
                           antiqueImg: antique.antiqueimg,
                           description: antique.desc ?? "-",
                           origin: antique.origin ?? "-",
                           eraPeriod: antique.eraPeriod ?? "-",
                           historicalContext: antique.historicalContext ?? "-",
                           estimatedValueUSD: AntiqueModel.EstimatedValue(
                               min: antique.estimatedValueMin,
                               max: antique.estimatedValueMax
                           ),
                           condition: "-",
                           rarityScore: 0,
                           makers: antique.makers ?? "-",
                           materials: "-",
                           dimension: "-",
                           craftsmanshipStyle: "-",
                           visualMatches: [],
                           isDefault: antique.isDefault, category: antique.category
                       )
                   } ?? []
                   
                   return AntiqueCollectionModel(
                       name: collection.name ?? "-",
                       id: collection.id ?? UUID(),
                       createdAt: collection.createdAt ?? Date(),
                       antiqueItems: antiques
                   )
               }
               
               print("✅ Found \(models.count) collections that do NOT contain antique '\(antiqueName)'")
               return models
               
           } catch {
               print("❌ Error fetching collections: \(error.localizedDescription)")
               return []
           }
       }
    
    static func fetchCollectionsNotContainingAntique(by antiqueId: UUID) -> [AntiqueCollectionModel] {
            let collectionRequest: NSFetchRequest<Collection> = Collection.fetchRequest()
               collectionRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            do {
                // 1️⃣ Fetch all collections
                let allCollections = try context.fetch(collectionRequest)
                
                // 2️⃣ Filter out collections that already include this antique
                let filteredCollections = allCollections.filter { collection in
                    guard let antiques = collection.antique as? Set<Antique> else { return true }
                    return !antiques.contains(where: { $0.id == antiqueId })
                }
                
                // 3️⃣ Transform to Model
                let models: [AntiqueCollectionModel] = filteredCollections.map { collection in
                    let antiques: [AntiqueModel] = (collection.antique as? Set<Antique>)?.compactMap { antique in
                        AntiqueModel(
                            id: antique.id,
                            name: antique.name ?? "-",
                            antiqueImg: antique.antiqueimg,
                            description: antique.desc ?? "-",
                            origin: antique.origin ?? "-",
                            eraPeriod: antique.eraPeriod ?? "-",
                            historicalContext: antique.historicalContext ?? "-",
                            estimatedValueUSD: AntiqueModel.EstimatedValue(
                                min: antique.estimatedValueMin,
                                max: antique.estimatedValueMax
                            ),
                            condition: "-",
                            rarityScore: 0,
                            makers: antique.makers ?? "-",
                            materials: "-",
                            dimension:  "-",
                            craftsmanshipStyle:  "-",
                            visualMatches: [],
                            isDefault: antique.isDefault, category: antique.category
                        )
                    } ?? []
                    
                    return AntiqueCollectionModel(
                        name: collection.name ?? "-",
                        id: collection.id ?? UUID(),
                        createdAt: collection.createdAt ?? Date(),
                        antiqueItems: antiques
                    )
                }
                
                print("✅ Found \(models.count) collections that do NOT contain this antique")
                return models
                
            } catch {
                print("❌ Error fetching collections: \(error.localizedDescription)")
                return []
            }
        }

}
