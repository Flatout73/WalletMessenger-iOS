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
    
    func insertConversation(id: Int, name: String, mobilePhone: Int, avatar: Data?) {
        
        container.performBackgroundTask { (context) in
            
        
        let user = User.findOrInsertUser(id: id, name: name, mobilePhone: mobilePhone, avatar: avatar, inContext: context)
        
        _ = Conversation.findOrInsertConversation(id: id, summa: 0.0, users: [user], transactions: [], inContext: context)
            
            context.saveThrows()
            self.dataBase.saveContext()
            
        }
        
//        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
//        
//        container.viewContext.performAndWait {
//            if let results = try? self.container.viewContext.fetch(request) {
//                print("\(results.count) TweetMs")
//                for result in results{
//                    print(result.conversationID, result.summa)
//                }
//            }
//        }
    }
    
}

