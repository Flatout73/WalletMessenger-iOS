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
    private class func insertTransaction(id: Int, money: Double, text: String, date: Date, isCash: Bool, conversation: Int?, group: Int?, reciver: Int, sender: Int, inContext context: NSManagedObjectContext) -> Transaction {
        
        
        let transaction = Transaction(context: context)
        transaction.money = money
        transaction.text = text
        transaction.date = date as NSDate?
        transaction.isCash = isCash
        
        guard let rec = User.findUser(id: reciver, inContext: context), let sen = User.findUser(id: sender, inContext: context) else {
            print("Что-то пошло не так при создании транзакции")
            return transaction
        }
        
        transaction.reciever = rec
        transaction.sender = sen
        
        
        if let conversationID = conversation{
            if let conv = Conversation.findConversation(id: conversationID, inContext: context){
                conv.addToTransactions(transaction)
            }
        } else {
            //доделать для группы
        }
        
//        if let conv = conversation {
//            conv.addToTransactions(transaction)
//        } else {
//            group?.addToTransactions(transaction)
//        }
        
        return transaction
    }
    
    class func findOrInsertTransaction(id: Int, money: Double, text: String, date: Date, isCash: Bool, conversation: Int?, group: Int?, reciver: Int, sender: Int, inContext context: NSManagedObjectContext) -> Transaction  {
        
        if let transaction = findTransaction(id: id, inContext: context) {
            transaction.money = money
            transaction.text = text
            transaction.date = date as NSDate
            transaction.isCash = isCash
            
            guard let rec = User.findUser(id: reciver, inContext: context), let sen = User.findUser(id: sender, inContext: context) else {
                print("Что-то пошло не так при создании транзакции")
                return transaction
            }
            
            transaction.reciever = rec
            transaction.sender = sen
        
            if let conversationID = conversation{
                if let conv = Conversation.findConversation(id: conversationID, inContext: context){
                    conv.addToTransactions(transaction)
                }
            } else {
                //доделать для группы
            }
            
//            if let conv = Conversation.findConversation(id: conversation, inContext: context) {
//                conv.addToTransactions(transaction)
//            } else {
//                group?.addToTransactions(transaction)
//            }
            
            return transaction
        } else {
            return insertTransaction(id: id, money: money, text: text, date: date, isCash: isCash, conversation: conversation, group: group, reciver: reciver, sender: sender, inContext: context)
        }
        
    }
    
    class func findTransaction(id: Int, inContext context: NSManagedObjectContext) -> Transaction? {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        
        request.predicate = NSPredicate(format: "transactionID==%@", String(id))
        
        if let transaction = (try? context.fetch(request))?.first {
            return transaction
        }
        
        return nil
    }
}
