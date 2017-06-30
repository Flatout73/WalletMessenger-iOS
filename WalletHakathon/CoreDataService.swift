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
    
    //var appUser: User!

    var appUserID: Int!
    
    //var backgroundContext: NSManagedObjectContext!
    
    public static let sharedInstance = CoreDataService()
    
    private override init() {
        super.init()
        container = dataBase.persistentContainer
        
        appUserID = UserDefaults.standard.integer(forKey: "appUserId")
        
        //let request: NSFetchRequest<User> = container.managedObjectModel.fetchRequestFromTemplate(withName: "UserWithId", substitutionVariables: ["USERID": userID]) as! NSFetchRequest<User>
        
        
//        
//        do{
//            let result = try container.viewContext.fetch(request)
//            appUser = result.first
//        } catch{
//            print(error.localizedDescription)
//        }
//        
//        container.performBackgroundTask { (context) in
//            self.backgroundContext = context
//        }
        
    }
    
    func getAppUser(in context: NSManagedObjectContext) -> User {
        let userID = UserDefaults.standard.integer(forKey: "appUserId")
        
        let user = User.findUser(id: userID, inContext: context)!
        return user
    }
    
    func createAppUser(phone:Int64, name: String, id: Int, avatar: Data?){
        
        appUserID = id
        container.performBackgroundTask { (context) in
            _ = User.findOrInsertUser(id: id, name: name, mobilePhone: phone, avatar: avatar, inContext: context)
            
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
    
    func insertConversation(userID: Int, conversationID: Int, date: Date,  name: String, mobilePhone: Int64, balance: Double, avatar: Data?) {
        
        
        //возможно стоит это вынести вне метода
        container.performBackgroundTask { (context) in
            
        
        let user = User.findOrInsertUser(id: userID, name: name, mobilePhone: mobilePhone, avatar: avatar, inContext: context)
        
            _ = Conversation.findOrInsertConversation(id: conversationID, summa: balance, date: date, users: [user], transactions: [], inContext: context)
            
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
    
    func insertTransaction(id: Int, money: Double, text: String, date: Date, isCash: Bool, proof: Int, conversation: Int?, group: Int?, userID: Int) {
        
        container.performBackgroundTask { (context) in
            
            //            context.automaticallyMergesChangesFromParent = true
            //            self.container.viewContext.automaticallyMergesChangesFromParent = true
            //
            if let conversationID = conversation{
                let convers = Conversation.findConversation(id: conversationID, inContext: context)
                guard let participant = convers?.participant else {
                    print("Нет собеседника в диалоге")
                    return
                }
                
                let appUser = self.getAppUser(in: context)
                
                print("ID пользователя приложения", appUser.userID)
                
                if (appUser.userID == Int32(userID)){
                    _ = Transaction.findOrInsertTransaction(id: id, money: money, text: text, date: date, isCash: isCash, proof: proof, conversation: conversation, group: nil, reciver: Int(participant.userID), sender: Int(appUser.userID), inContext: context)
                } else {
                    _ = Transaction.findOrInsertTransaction(id: id, money: money, text: text, date: date, isCash: isCash, proof: proof, conversation: conversation, group: nil, reciver: Int(appUser.userID), sender: userID, inContext: context)
                }
            }
            
            context.saveThrows()
            self.dataBase.saveContext()
        }
        
        //                let request: NSFetchRequest<Transaction> = container.managedObjectModel.fetchRequestFromTemplate(withName: "TransactionsWithConversationId", substitutionVariables: ["CONVERSATIONID": String(conversation!.conversationID)]) as! NSFetchRequest<Transaction>
        //
        //                container.viewContext.performAndWait {
        //                    if let results = try? self.container.viewContext.fetch(request) {
        //                        print("\(results.count) TweetMs")
        //                        for result in results{
        //                            print(result.transactionID, result.money)
        //                        }
        //                    }
        //                }
        
    }
    
    func insertTransaction(id: Int, money: Double, text: String, date: Date, isCash: Bool, proof: Int, conversation: Int?, group: Int?, reciver: Int, sender: Int) {
        
        container.performBackgroundTask { (context) in
            if let conversationID = conversation{
                let convers = Conversation.findConversation(id: conversationID, inContext: context)
                guard let participant = convers?.participant else {
                    print("Нет собеседника в диалоге")
                    return
                }
                
                _ = Transaction.findOrInsertTransaction(id: id, money: money, text: text, date: date, isCash: isCash, proof: proof, conversation: conversation, group: nil, reciver: reciver, sender: sender, inContext: context)
            }
            
            context.saveThrows()
            self.dataBase.saveContext()
        }
        
    }
    
    func changeName(name: String) {
        container.performBackgroundTask { (context) in
            
            let appUser = self.getAppUser(in: context)
            appUser.name = name
            
            context.saveThrows()
            self.dataBase.saveContext()
        }
    }
    
    func changePhoto(photo: Data) {
        container.performBackgroundTask { (context) in
            
            let appUser = self.getAppUser(in: context)
            appUser.avatar = photo as NSData
            
            context.saveThrows()
            self.dataBase.saveContext()
        }
    }
    
    func findUserBy(id: Int) -> User? {
        
        var user: User?

        container.viewContext.performAndWait {
            user = User.findUser(id: id, inContext: self.container.viewContext)
        }
       return user
    }
    
    func findConversaionBy(id: Int) -> Conversation? {
        var conversation: Conversation?
        container.viewContext.performAndWait {
            conversation = Conversation.findConversation(id: id, inContext: self.container.viewContext)
        }
        return conversation
    }
    
}
