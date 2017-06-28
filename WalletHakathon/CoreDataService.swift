//
//  CoreDataService.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 27.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataService: NSObject {
    
    let dataBase = DataBase()
    
    var container: NSPersistentContainer!
    
    var tableView: UITableView!
    
    override init() {
        super.init()
        container = dataBase.persistentContainer
    }
    
    func getFRCForChats() -> NSFetchedResultsController<Conversation>{
        var fetchedResultsController: NSFetchedResultsController<Conversation>
        
        let fetchRequest: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "conversationID", ascending: true)
        //let sortDescriptor2 = NSSortDescriptor(key: "summa", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchBatchSize = 20
        
        fetchedResultsController = NSFetchedResultsController<Conversation>(fetchRequest:
            fetchRequest, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }
    
    func insertConversation(id: Int) {
        
        container.performBackgroundTask { (context) in
            
        
        let user = User.findOrInsertUser(id: id, name: "Druc", mobilePhone: 234567, avatar: nil, inContext: context)
        
        _ = Conversation.findOrInsertConversation(id: id + 100, summa: Double(12+id), users: [user], transactions: [], inContext: context)
            
            context.saveThrows()
            self.dataBase.saveContext()
            try! self.container.viewContext.save()
            
        }
        
        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        
        container.viewContext.perform {
            if let results = try? self.container.viewContext.fetch(request) {
                print("\(results.count) TweetMs")
                for result in results{
                    print(result.conversationID, result.summa)
                }
            }
        }
    }
    
}

