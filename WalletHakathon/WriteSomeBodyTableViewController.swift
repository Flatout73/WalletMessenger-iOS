//
//  WriteSomeBodyTableViewController.swift
//  WalletHakathon
//
//  Created by Андрей on 29.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit

class WriteSomeBodyTableViewController: UITableViewController {

    @IBOutlet var phoneNumberTextField: UITextField!
    var dialogID = 0
    
    func close(){
        _ = navigationController?.popToRootViewController(animated: false)
        
        if let vc = navigationController?.viewControllers.first as? DialogDelegateCaller{
            vc.callDialogDelegate(withDialogID: dialogID)
        }
        
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 1){
            ServiceAPI.createDialog(phoneNumber: phoneNumberTextField.text!, noncompletedHandler: {_ in }, completionHandler: { self.close() })
        }
    }
}
