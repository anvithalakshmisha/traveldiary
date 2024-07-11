//
//  Persistence.swift
//  TravelDiary
//
//  Created by Bhavesh Raja on 11/04/24.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    // Add a static variable for preview
    static var preview: PersistenceController {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        // Populate the in-memory database for previews here if needed
        return result
    }

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        ValueTransformer.setValueTransformer(ImageTransformer(), forName: NSValueTransformerName("ImageTransformer"))
        
        container = NSPersistentContainer(name: "TravelDiary")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                // Real apps should handle the error appropriately
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            print("Database URL: \(storeDescription.url?.absoluteString ?? "Not found")")

        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

