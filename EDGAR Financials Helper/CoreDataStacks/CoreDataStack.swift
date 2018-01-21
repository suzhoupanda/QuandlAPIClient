//
//  CoreDataStack.swift
//  EDGAR Financials Helper
//
//  Created by Aleksander Makedonski on 12/17/17.
//  Copyright © 2017 Aleksander Makedonski. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack{
    

    var managedContext: NSManagedObjectContext{
        return persistentContainer.viewContext
    }


    var modelName: String

    init(withModelName modelName: String) {
    
        self.modelName = modelName
    }

    lazy private var persistentContainer: NSPersistentContainer = {
    
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
            
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext(){
        do {
            print("Performing save...")
            try self.managedContext.save()
            print("Save completed...")
            
        } catch let error as NSError {
            print("Error: unable to save data: \(error.localizedDescription)")
        }
    }
}

