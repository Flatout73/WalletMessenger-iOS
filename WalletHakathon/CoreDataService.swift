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
    var mobilePhone: Int64!
    
    //var backgroundContext: NSManagedObjectContext!
    
    public static let sharedInstance = CoreDataService()
    
    private override init() {
        super.init()
        container = dataBase.persistentContainer
        
        appUserID = UserDefaults.standard.integer(forKey: "appUserId")
        if let phone = UserDefaults.standard.object(forKey: "mobilePhone") as? Int64{
            mobilePhone = phone
        }
        
        //container.viewContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
        
        //let request: NSFetchRequest<User> = container.managedObjectModel.fetchRequestFromTemplate(withName: "UserWithId", substitutionVariables: ["USERID": userID]) as! NSFetchRequest<User>
        
        
//        
//        do{
//            let result = try container.viewContext.fetch(request)
//            appUser = result.first
//        } catch{
//            print(error.localizedDescription)
//        }
//        
        container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
        }
        
    }
    
    func getAppUser(in context: NSManagedObjectContext) -> User {
        let userID = UserDefaults.standard.integer(forKey: "appUserId")
        
        let user = User.findUser(id: userID, inContext: context)!
        return user
    }
    
    func createAppUser(phone:Int64, name: String, id: Int, avatar: Data?){
        
        appUserID = id
        mobilePhone = phone
        UserDefaults.standard.set(phone, forKey: "mobilePhone")
        
        container.performBackgroundTask { (context) in
            _ = User.findOrInsertUser(id: id, name: name, mobilePhone: phone, avatar: avatar, inContext: context)
            
            context.saveThrows()
            self.dataBase.saveContext()
        }
    }
    
    func getFRCForChats() -> NSFetchedResultsController<Conversation>{
        var fetchedResultsController: NSFetchedResultsController<Conversation>
        
        let fetchRequest: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        //let sortDescriptor2 = NSSortDescriptor(key: "summa", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchBatchSize = 20
        
        fetchedResultsController = NSFetchedResultsController<Conversation>(fetchRequest:
            fetchRequest, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }
    
    func getFRCForGroups() -> NSFetchedResultsController<GroupConversation> {
        var fetchedResultsController: NSFetchedResultsController<GroupConversation>
        
        let fetchRequest: NSFetchRequest<GroupConversation> = GroupConversation.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        //let sortDescriptor2 = NSSortDescriptor(key: "summa", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchBatchSize = 20
        
        fetchedResultsController = NSFetchedResultsController<GroupConversation>(fetchRequest:
            fetchRequest, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }
    
    func getFRCForTransactions(dialogID: Int) -> NSFetchedResultsController<Transaction> {
        
        let fetchRequst: NSFetchRequest<Transaction> = container.managedObjectModel.fetchRequestFromTemplate(withName: "TransactionsWithConversationId", substitutionVariables: ["CONVERSATIONID": String(dialogID)]) as! NSFetchRequest<Transaction>
        
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        fetchRequst.sortDescriptors = [sortDescriptor]
        fetchRequst.fetchBatchSize = 20
        
        return NSFetchedResultsController<Transaction>(fetchRequest: fetchRequst, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    
    func getFRCForTransactions(groupID: Int) -> NSFetchedResultsController<Transaction> {
        
        let fetchRequst: NSFetchRequest<Transaction> = container.managedObjectModel.fetchRequestFromTemplate(withName: "TransactionsWithGroupId", substitutionVariables: ["CONVERSATIONID": String(groupID)]) as! NSFetchRequest<Transaction>
        
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        fetchRequst.sortDescriptors = [sortDescriptor]
        fetchRequst.fetchBatchSize = 20
        
        return NSFetchedResultsController<Transaction>(fetchRequest: fetchRequst, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func getParticipants(groupID: Int) -> [User] {
        
        var user: [User] = []
        container.viewContext.performAndWait {
            let group = GroupConversation.findConversation(id: groupID, inContext: self.container.viewContext)
            
            if let participants = group?.participants {
                user = participants.array as! [User]
            }
        }
        
        return user
    }
    
    func destroyCoreData() {
        
        container.performBackgroundTask { (context) in
            
            do {
                var fetchReq: NSFetchRequest<NSFetchRequestResult> = Conversation.fetchRequest()
                // Create Batch Delete Request
                var batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchReq)
                try context.execute(batchDeleteRequest)
                
                fetchReq = Transaction.fetchRequest()
                batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchReq)
                try context.execute(batchDeleteRequest)
                
                fetchReq = GroupConversation.fetchRequest()
                batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchReq)
                try context.execute(batchDeleteRequest)
                
                fetchReq = User.fetchRequest()
                batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchReq)
                try context.execute(batchDeleteRequest)
                
                context.saveThrows()
                self.dataBase.saveContext()
                
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    func deleteGroup(groupID: Int, completionHandler: @escaping() -> Void){
        container.performBackgroundTask{ (context) in
            context.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
            
            
            let group = GroupConversation.findConversation(id: groupID, inContext: context)
            
            if let group = group{
                context.delete(group)
            }
            context.saveThrows()
            self.dataBase.saveContext()
            
            completionHandler()
        }
    }
    
    func insertConversation(userID: Int, conversationID: Int, date: Date,  name: String, mobilePhone: Int64, balance: Double, avatar: Data?, completionHandler: @escaping() -> Void) {
        
        
        //возможно стоит это вынести вне метода
        container.performBackgroundTask { (context) in
            
        context.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
            
        let user = User.findOrInsertUser(id: userID, name: name, mobilePhone: mobilePhone, avatar: avatar, inContext: context)
        
            _ = Conversation.findOrInsertConversation(id: conversationID, summa: balance, date: date, users: [user], transactions: [], inContext: context)
            
            context.saveThrows()
            self.dataBase.saveContext()
            
            completionHandler()
        }
    }
    
        func insertGroup(groupID: Int, name: String, date: Date, summa: Double, myBalance: Double, adminID: Int, completionHandler: @escaping() -> Void){
            
            container.performBackgroundTask { (context) in
                context.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
                
                var admin = User.findUser(id: adminID, inContext: context)
                if (admin == nil) {
                    admin = User.findOrInsertUser(id: adminID, name: "", mobilePhone: 0, avatar: nil, inContext: context)
                }
                
                _ = GroupConversation.findOrInsertConversation(id: groupID, summa: summa, name: name, balance: myBalance, date: date, admin: admin!, users: [], transactions: [], inContext: context)
                
                context.saveThrows()
                self.dataBase.saveContext()
                
                completionHandler()
            }
        }
        
    func insertGroupUsers(groupID: Int, userID: Int, balance: Double, name: String, phone: Int64, avatar: Data?, completionHandler: @escaping() -> Void) {
            container.performBackgroundTask { (context) in
                
                context.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
                
                if(userID == self.appUserID) {
                    
                }
                
                let user = User.findOrInsertUser(id: userID, name: name, mobilePhone: phone, avatar: avatar, inContext: context)
                
                let group = GroupConversation.findConversation(id: groupID, inContext: context)
                
                user.addToGroupConversations(group!)
                //group!.addToParticipants(user)
                
                context.saveThrows()
                self.dataBase.saveContext()
            }
        }

    
    
    var k = 0
    
    func clearK(){
        k = 0
    }
    
    func incrementK(){
        k+=1
    }
    
    
    func insertTransaction(id: Int, money: Double, text: String, date: Date, isCash: Bool, proof: Int, conversation: Int?, group: Int?, userID: Int, count: Int = 0, completionHandler: @escaping() -> Void) {
        
        container.performBackgroundTask { (context) in
            
            context.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
            
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
                
                //print("ID пользователя приложения", appUser.userID)
                
                if (appUser.userID == Int32(userID)){
                    _ = Transaction.findOrInsertTransaction(id: id, money: money, text: text, date: date, isCash: isCash, proof: proof, conversation: conversation, group: nil, reciver: Int(participant.userID), sender: Int(appUser.userID), inContext: context)
                } else {
                    _ = Transaction.findOrInsertTransaction(id: id, money: money, text: text, date: date, isCash: isCash, proof: proof, conversation: conversation, group: nil, reciver: Int(appUser.userID), sender: userID, inContext: context)
                }
            }
            
            //self.incrementK()
            
            //if(self.k >= count){
                context.saveThrows()
                self.dataBase.saveContext()
                self.k = 0
                
                completionHandler()
            //}
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
    
    func insertTransaction(id: Int, money: Double, text: String, date: Date, isCash: Bool, proof: Int, conversation: Int?, group: Int?, reciver: Int, sender: Int, count: Int = 0, completionHandler: @escaping() -> Void) {
        
        container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
            
//            if let conversationID = conversation{
//                let convers = Conversation.findConversation(id: conversationID, inContext: context)
//                guard let participant = convers?.participant else {
//                    print("Нет собеседника в диалоге")
//                    return
//                }
                
                _ = Transaction.findOrInsertTransaction(id: id, money: money, text: text, date: date, isCash: isCash, proof: proof, conversation: conversation, group: group, reciver: reciver, sender: sender, inContext: context)
//            } else if let groupID = group {
//               
//               _ = Transaction.findOrInsertTransaction(id: id, money: money, text: text, date: date, isCash: isCash, proof: proof, conversation: conversation, group: goup, reciver: reciver, sender: sender, inContext: context)
//                
//            }
            
            //if(self.k >= count){
                context.saveThrows()
                self.dataBase.saveContext()
                self.k = 0
                
                completionHandler()
            //}
        }
        
    }
    
    func acceptTransactionOrNot(id:Int, accept: Int, completionHandler: @escaping() -> Void) {
        container.performBackgroundTask { (context) in
            guard let transaction = Transaction.findTransaction(id: id, inContext: context) else {
                print("Нет такой транзакции")
                return
            }
            
            transaction.proof = Int16(accept)
            context.saveThrows()
            self.dataBase.saveContext()
            
            completionHandler()
        }
    }
    
    func changeName(name: String) {
        container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
            
            let appUser = self.getAppUser(in: context)
            appUser.name = name
            
            context.saveThrows()
            self.dataBase.saveContext()
        }
    }
    
    func changePhoto(photo: Data) {
        container.performBackgroundTask { (context) in
            
            context.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
            
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
