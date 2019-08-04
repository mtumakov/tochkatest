//
//  DBOperations.swift
//  tochkatest
//
//  Created by Mihail Tumakov on 28/07/2019.
//  Copyright © 2019 Mihail Tumakov. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DBOperations {
    let appDelegate: AppDelegate
    let managedContext: NSManagedObjectContext
    let entityName = "DbItem"
    
    init() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.persistentContainer.viewContext
    }
    
    func loadItems(searchText: String?) -> [Item] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let fetchedResults: [NSManagedObject]?
        
        let titleSortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [titleSortDescriptor]
        
        if let text = searchText {
            let predicate = NSPredicate(format: "title contains[c] %@", text)
            fetchRequest.predicate = predicate
        }
        
        var resultArray = [Item]()
        do {
            fetchedResults = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            if let results = fetchedResults {
                for iter in results {
                    let item = Item(title: iter.value(forKey: "title") as! String,
                                    description: iter.value(forKey: "content") as! String,
                                    urlToImage: iter.value(forKey: "urlToImage") as? URL,
                                    publishedAt: iter.value(forKey: "publishedAt") as! Date)
                    resultArray.append(item)
                }
            } else {
            }
        } catch {
            print("Could not fetch: \(error)")
        }
        return resultArray
    }
    
    func saveItems(itemArray: [Item]) {
        let entity =  NSEntityDescription.entity(forEntityName: entityName, in: managedContext)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        for item in itemArray {
            fetchRequest.predicate = NSPredicate(format: "title = %@", item.title)
            do {
                if let fetchResults = try managedContext.fetch(fetchRequest) as? [NSManagedObject] {
                    if fetchResults.count == 0 {
                        
                        let dbItem = NSManagedObject(entity: entity!, insertInto: managedContext)
                        dbItem.setValue(item.title, forKey: "title")
                        dbItem.setValue(item.description, forKey: "content")
                        dbItem.setValue(item.urlToImage, forKey: "urlToImage")
                        try managedContext.save()
                    }
                }
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    func deleteAllEntities() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let fetchedResults: [NSManagedObject]?
        do {
            fetchedResults = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            if let results = fetchedResults {
                
                for iter in results {
                    managedContext.delete(iter)
                }
            }
            try managedContext.save()
        } catch {
            print("Could not fetch: \(error)")
        }
    }
    
    func getCountInDb() -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let fetchedResults: [NSManagedObject]?
        do {
            fetchedResults = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            if let count = fetchedResults?.count {
                return count
            }
        } catch {
            print("Could not fetch: \(error)")
        }
        return 0
    }
}
