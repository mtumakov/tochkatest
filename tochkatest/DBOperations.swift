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

extension MainViewController {

    func deleteFromStorage() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"DbItem")
        let fetchedResults: [NSManagedObject]?
        do {
            fetchedResults = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            if let results = fetchedResults {
                
                for iter in results {
                    managedContext.delete(iter)
                }
            } else {
            }
            try managedContext.save()
        } catch {
            print("Could not fetch: \(error)")
        }
    }
    
    func loadItems() -> [Item] {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"DbItem")
        let fetchedResults: [NSManagedObject]?

        var resultArray = [Item]()
        do {
            fetchedResults = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            if let results = fetchedResults {
                for iter in results {
                    let item = Item(title: iter.value(forKey: "title") as! String,
                                    content: iter.value(forKey: "content") as! String,
                                    imageLink: iter.value(forKey: "imageLink") as? String)
                    resultArray.append(item)
                }
            } else {
            }
        } catch {
            print("Could not fetch: \(error)")
        }
        print("loading data")
        tableData = resultArray
        print("prepare to reload data")
        self.tableView.reloadData()
        print("data reloaded")
        return resultArray
    }
    
    func getCountInDb() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"DbItem")
        let fetchedResults: [NSManagedObject]?
        do {
            fetchedResults = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
            print("count in db - \(fetchedResults!.count)")
        } catch {
            print("Could not fetch: \(error)")
        }
    }
}
