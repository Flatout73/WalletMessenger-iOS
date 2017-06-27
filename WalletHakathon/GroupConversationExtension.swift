//
//  GroupConversationExtension.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 27.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import Foundation


import Foundation
import CoreData

extension GroupConversation {
    private class func insertConversation(id: Int, summa: Double, name: String, users: [User], transactions: [Transaction], inContext context: NSManagedObjectContext) -> GroupConversation{
        let conversation = GroupConversation(context: context)
        conversation.conversationID = Int32(id)
        conversation.summa = summa
        conversation.name = name
        for user in users {
            conversation.addToParticipants(user)
        }
        
        for transaction in transactions {
            conversation.addToTransactions(transaction)
        }
        return conversation
    }
    
    class func findOrInsertConversation(id: Int, summa: Double, name: String, users: [User], transactions: [Transaction], inContext context: NSManagedObjectContext) -> GroupConversation {
        
        if let conversation = findConversation(id: id, inContext: context) {
            conversation.summa = summa
            conversation.name = name
            for user in users {
                conversation.addToParticipants(user)
            }
            
            for transaction in transactions {
                conversation.addToTransactions(transaction)
            }
            
            return conversation
        } else {
            return insertConversation(id: id, summa: summa, name: name, users: users, transactions: transactions, inContext: context)
        }
        
    }
    
    class func findConversation(id: Int, inContext context: NSManagedObjectContext) -> GroupConversation? {
        let request: NSFetchRequest<GroupConversation> = GroupConversation.fetchRequest()
        
        request.predicate = NSPredicate(format: "conversationID==%@", id)
        
        if let conversation = (try? context.fetch(request))?.first {
            return conversation
        }
        
        return nil
    }
}
