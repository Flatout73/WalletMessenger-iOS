//
//  TransactionExtension.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 27.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//


import Foundation
import CoreData

extension Transaction {
    private class func insertTransaction(id: Int, money: Double, text: String, date: Date, isCash: Bool, conversation: Conversation?, group: GroupConversation?, reciver: User, sender: User, inContext context: NSManagedObjectContext) -> Transaction {
        let transaction = Transaction(context: context)
        transaction.money = money
        transaction.text = text
        transaction.date = date as NSDate
        transaction.isCash = isCash
        
        transaction.reciever = reciver
        transaction.sender = sender
        
        if let conv = conversation {
            conv.addToTransactions(transaction)
        } else {
            group?.addToTransactions(transaction)
        }
        
        return transaction
    }
    
    class func findOrInsertTransaction(id: Int, money: Double, text: String, date: Date, isCash: Bool, conversation: Conversation?, group: GroupConversation?, reciver: User, sender: User, inContext context: NSManagedObjectContext) -> Transaction  {
        
        if let transaction = findTransaction(id: id, inContext: context) {
            transaction.money = money
            transaction.text = text
            transaction.date = date as NSDate
            transaction.isCash = isCash
            
            transaction.reciever = reciver
            transaction.sender = sender
        
            if let conv = conversation {
                conv.addToTransactions(transaction)
            } else {
                group?.addToTransactions(transaction)
            }
            
            return transaction
        } else {
            return insertTransaction(id: id, money: money, text: text, date: date, isCash: isCash, conversation: conversation, group: group, reciver: reciver, sender: sender, inContext: context)
        }
        
    }
    
    class func findTransaction(id: Int, inContext context: NSManagedObjectContext) -> Transaction? {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        
        request.predicate = NSPredicate(format: "transactionID=%@", id)
        
        if let transaction = (try? context.fetch(request))?.first {
            return transaction
        }
        
        return nil
    }
}
