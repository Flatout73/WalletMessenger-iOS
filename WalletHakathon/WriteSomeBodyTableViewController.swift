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
    
    var dialogDelegate: ContactDialogDelegate?
    var groupDelegate: ContactGroupDelegate?
    
    func close(){
        DispatchQueue.main.async {[weak self] in
            _ = self?.navigationController?.popToRootViewController(animated: false)
            self?.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
            self?.dialogDelegate?.openDialog(withID: (self?.dialogID)!)
        }
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 1){
            ServiceAPI.createDialog(phoneNumber: phoneNumberTextField.text!, noncompletedHandler: {(str) in ServiceAPI.alert(viewController: self, desc: str)}, completionHandler:
                { (dialog) in
                    self.dialogID = dialog
                    self.close()
            })
        }
    }
}
