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
    
    var appUser: User!
    
    public static let sharedInstance = CoreDataService()
    
    private override init() {
        super.init()
        container = dataBase.persistentContainer
        
        let userID = UserDefaults.standard.integer(forKey: "appUserId")
        
        let request: NSFetchRequest<User> = container.managedObjectModel.fetchRequestFromTemplate(withName: "UserWithId", substitutionVariables: ["USERID": userID]) as! NSFetchRequest<User>
        
        
        
        do{
            let result = try container.viewContext.fetch(request)
            appUser = result.first
        } catch{
            print(error.localizedDescription)
        }
        
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
    
    func insertConversation(userID: Int, conversationID: Int,  name: String, mobilePhone: Int, balance: Double, avatar: Data?) {
        
        
        //возможно стоит это вынести вне метода
        container.performBackgroundTask { (context) in
            
        
        let user = User.findOrInsertUser(id: userID, name: name, mobilePhone: mobilePhone, avatar: avatar, inContext: context)
        
        _ = Conversation.findOrInsertConversation(id: conversationID, summa: balance, users: [user], transactions: [], inContext: context)
            
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
    
    func insertTransaction(id: Int, money: Double, text: String, date: Date, isCash: Bool, conversation: Conversation?, group: GroupConversation?, reciver: User?, sender: User?) {
        
        container.performBackgroundTask { (context) in
            
            if let user = reciver{
                Transaction.findOrInsertTransaction(id: id, money: money, text: text, date: date, isCash: isCash, conversation: conversation, group: group, reciver: user, sender: self.appUser, inContext: context)
            } else {
                Transaction.findOrInsertTransaction(id: id, money: money, text: text, date: date, isCash: isCash, conversation: conversation, group: group, reciver: self.appUser, sender: sender!, inContext: context)
            }
            
            context.saveThrows()
            self.dataBase.saveContext()
        }
        
    }
    
    func findUserBy(id: String) -> User? {
       return User.findUser(id: Int(id)!, inContext: container.viewContext)
    }
    
}

