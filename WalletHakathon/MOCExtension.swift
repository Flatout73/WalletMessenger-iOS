//
//  MOCExtension.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 27.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext
{
    public func saveThrows () {
        if self.hasChanges {
            do {
                try save()
            } catch let error  {
                let nserror = error as NSError
                print("Core Data Error:  \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
