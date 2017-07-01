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
    var root:UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Создать диалог"
    }
    
    func close(withInfo: DialogInfo){
        DispatchQueue.main.async {[weak self] in
            _ = self?.navigationController?.popToRootViewController(animated: false)
            self?.root?.dismiss(animated: true, completion: nil)
            self?.dialogDelegate?.openDialog(withDialogInfo: withInfo)
        }
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 1){
            
            let phoneStr = StringService.getClearPhone(byString: phoneNumberTextField.text!)
            
            if let phone = CoreDataService.sharedInstance.mobilePhone, Int64(phoneStr) !=  phone{
                ServiceAPI.getByPhone(phoneNumber: phoneStr , noncompletedHandler: {str in ServiceAPI.alert(viewController: self, desc: str)}, completionHandler: { us in
                    ServiceAPI.createDialogWithUser(user: us, noncompletedHandler: {str in ServiceAPI.alert(viewController: self, desc: str)}, completionHandler: { dialogID in
                        let dialogInfo = DialogInfo()
                        dialogInfo.dialogID = dialogID
                        dialogInfo.user = us
                        self.close(withInfo: dialogInfo)
                    })
                })
            } else {
                ServiceAPI.alert(viewController: self, desc: "Пожалуйста введите другой номер телефона")
            }
        }
    }
}
