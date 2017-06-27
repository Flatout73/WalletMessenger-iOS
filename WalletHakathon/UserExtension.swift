//
//  UserExtension.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 27.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import Foundation
import CoreData

extension User {
    private class func insertUser(id: Int, name: String, mobilePhone: Int, avatar: Data, conversations: [Conversation], groups: [GroupConversation], ownerOf: [GroupConversation], inContext context: NSManagedObjectContext) -> User {
        let user = User(context: context)
        user.userID = Int32(id)
        user.name = name
        user.mobilePhone = Int16(mobilePhone)
        user.avatar = avatar as NSData
        for conversation in conversations {
            conversation.addToParticipants(user)
        }
        return user
    }
    
    class func findOrInsertUser(id: Int, name: String, mobilePhone: Int, avatar: Data, conversations: [Conversation], groups: [GroupConversation], ownerOf: [GroupConversation], inContext context: NSManagedObjectContext) -> User  {
        
        if let user = findUser(id: id, inContext: context) {
            user.name = name
            user.mobilePhone = Int16(mobilePhone)
            user.avatar = avatar as NSData
            for conversation in conversations {
                conversation.addToParticipants(user)
            }
            
            return user
        } else {
            return insertUser(id: id, name: name, mobilePhone: mobilePhone, avatar:
                avatar, conversations: conversations, groups: groups, ownerOf: ownerOf, inContext: context)
        }
        
    }
    
    class func findUser(id: Int, inContext context: NSManagedObjectContext) -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        
        request.predicate = NSPredicate(format: "userID=%@", id)
        
        if let user = (try? context.fetch(request))?.first {
            return user
        }
        
        return nil
    }
}
