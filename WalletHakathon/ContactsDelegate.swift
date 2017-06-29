//
//  ContactsDelegate.swift
//  WalletHakathon
//
//  Created by Андрей on 29.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import Foundation

protocol ContactsDialogDelegate {
    func openDialog(id withID:Int)
}

protocol ContactsGroupDelegate {
    func openGroup(id withID:Int)
}
