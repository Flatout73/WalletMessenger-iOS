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
    
    func createAppUser(phone:Int, name: String, id: Int, avatar: Data?){
        
        container.performBackgroundTask { (context) in
            self.appUser = User.findOrInsertUser(id: id, name: name, mobilePhone: phone, avatar: avatar, inContext: context)
            
            context.saveThrows()
            self.dataBase.saveContext()
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
    
    func getFRCForTransactions(dialogID: Int) -> NSFetchedResultsController<Transaction> {
        
        let fetchRequst: NSFetchRequest<Transaction> = container.managedObjectModel.fetchRequestFromTemplate(withName: "TransactionsWithConversationId", substitutionVariables: ["CONVERSATIONID": String(dialogID)]) as! NSFetchRequest<Transaction>
        
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        
        fetchRequst.sortDescriptors = [sortDescriptor]
        fetchRequst.fetchBatchSize = 20
        
        return NSFetchedResultsController<Transaction>(fetchRequest: fetchRequst, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    //надо протестить
    func destroyCoreData() {
        do {
            try container.persistentStoreCoordinator.destroyPersistentStore(at: URL(string: "WalletHakathon")!, ofType: NSSQLiteStoreType, options: nil)
        } catch {
            print(error.localizedDescription)
        }
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
            
            context.automaticallyMergesChangesFromParent = true
            self.container.viewContext.automaticallyMergesChangesFromParent = true
            
            if let user = reciver{
                Transaction.findOrInsertTransaction(id: id, money: money, text: text, date: date, isCash: isCash, conversation: Int((conversation?.conversationID)!), group: nil, reciver: Int(user.userID), sender: Int(self.appUser.userID), inContext: context)
            } else {
                Transaction.findOrInsertTransaction(id: id, money: money, text: text, date: date, isCash: isCash, conversation: Int((conversation?.conversationID)!), group: nil, reciver: Int(self.appUser.userID), sender: Int(sender!.userID), inContext: context)
            }
            
            context.saveThrows()
            self.dataBase.saveContext()
        }
        
                let request: NSFetchRequest<Transaction> = container.managedObjectModel.fetchRequestFromTemplate(withName: "TransactionsWithConversationId", substitutionVariables: ["CONVERSATIONID": String(conversation!.conversationID)]) as! NSFetchRequest<Transaction>
        
                container.viewContext.performAndWait {
                    if let results = try? self.container.viewContext.fetch(request) {
                        print("\(results.count) TweetMs")
                        for result in results{
                            print(result.transactionID, result.money)
                        }
                    }
                }
        
    }
    
    func findUserBy(id: Int) -> User? {
       return User.findUser(id: id, inContext: container.viewContext)
    }
    
    func findConversaionBy(id: Int) -> Conversation? {
        return Conversation.findConversation(id: id, inContext: container.viewContext)
    }
    
}

