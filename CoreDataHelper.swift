//
//  coreDataHelper.swift
//  iOS-AntiquesIdentifier
//
//  Created by Smit Savaliya on 27/10/25.
//

import CoreData

final class CoreDataHelper {
    static let shared = CoreDataHelper()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AntiqueModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
    
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    lazy var  context = persistentContainer.viewContext
    
     func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
              
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func clearAllData() {
        let entityNames = [""]
        
        for entityName in entityNames {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs
            
            do {
                let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
                if let objectIDs = result?.result as? [NSManagedObjectID] {
                    let changes = [NSDeletedObjectsKey: objectIDs]
                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
                }
                print("✅ Cleared all \(entityName) data")
            } catch {
                print("❌ Failed to clear \(entityName): \(error)")
            }
        }
    }
    
    func fetcheAll<T : NSManagedObject>(managesObject: T.Type) -> [T]? {
        do {
           let result = try CoreDataHelper.shared.context.fetch(managesObject.fetchRequest()) as? [T]
            return result
        }catch let error{
            print(error)
            return nil
        }
    }
}
