//
//  ConversationExtension.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 27.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import Foundation
import CoreData

extension Conversation {
    private class func insertConversation(id: Int, summa: Double, date: Date, users: [User], transactions: [Transaction], inContext context: NSManagedObjectContext) -> Conversation{
        let conversation = Conversation(context: context)
        conversation.conversationID = Int32(id)
        conversation.summa = summa

//        for user in users {
//            conversation.addToParticipants(user)
//        }
        
        conversation.participant = users.first
        conversation.date = date as NSDate
        
        for transaction in transactions {
            conversation.addToTransactions(transaction)
        }
        return conversation
    }
    
    class func findOrInsertConversation(id: Int, summa: Double, date: Date, users: [User], transactions: [Transaction], inContext context: NSManagedObjectContext) -> Conversation {
        
        if let conversation = findConversation(id: id, inContext: context) {
            conversation.summa = summa
//            for user in users {
//                conversation.addToParticipants(user)
//            }
            
            conversation.participant = users.first
            conversation.date = date as NSDate
            
            for transaction in transactions {
                conversation.addToTransactions(transaction)
            }
            
            return conversation
        } else {
            return insertConversation(id: id, summa: summa, date: date, users: users, transactions: transactions, inContext: context)
        }
        
    }
    
    class func findConversation(id: Int, inContext context: NSManagedObjectContext) -> Conversation? {
        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        
        request.predicate = NSPredicate(format: "conversationID==%@", String(id))
        
        if let conversation = (try? context.fetch(request))?.first {
            return conversation
        }
        
        return nil
    }
}
