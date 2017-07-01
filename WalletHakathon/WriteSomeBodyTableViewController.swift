//
//  WriteSomeBodyTableViewController.swift
//  WalletHakathon
//
//  Created by Андрей on 29.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit

class DialogInfo: NSObject {
    var dialogID = 0
    var user:UserForSend?
}

class WriteSomeBodyTableViewController: UITableViewController {

    @IBOutlet var phoneNumberTextField: UITextField!
    var dialogID = 0
    
    var dialogDelegate: ContactDialogDelegate?
    var groupDelegate: ContactGroupDelegate?
    
    func close(withInfo: DialogInfo){
        DispatchQueue.main.async {[weak self] in
            _ = self?.navigationController?.popToRootViewController(animated: false)
            self?.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
            self?.dialogDelegate?.openDialog(withDialogInfo: withInfo)
        }
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 1){
            ServiceAPI.getByPhone(phoneNumber: StringService.getClearPhone(byString: phoneNumberTextField.text!) , noncompletedHandler: {_ in}, completionHandler: { us in
                ServiceAPI.createDialogWithUser(user: us, noncompletedHandler: {_ in}, completionHandler: { dialogID in
                    let dialogInfo = DialogInfo()
                    dialogInfo.dialogID = dialogID
                    dialogInfo.user = us
                    self.close(withInfo: dialogInfo)
                })
            })
        }
    }
}
