//
//  GroupCreateTableViewController.swift
//  WalletHakathon
//
//  Created by Андрей on 29.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit

class GroupCreateTableViewController: UITableViewController {
    
    @IBOutlet var groupNameTextField: UITextField!
    
    var dialogDelegate: ContactDialogDelegate?
    var groupDelegate: ContactGroupDelegate?
    var root:UIViewController?
    
    var phones:[String] = []
    var groupID = 0
    
    func close(withID id: Int){
        DispatchQueue.main.async {[weak self] in
            self?.root?.dismiss(animated: true, completion: nil)
            self?.groupDelegate?.openGroup(withGroupID: id)
        }
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 1){
            if(groupNameTextField.text != ""){
                ServiceAPI.createGroupWithUsers(name: groupNameTextField.text!, phones: StringService.createPhones(byArray: phones), noncompletedHandler: {str in
                    
                ServiceAPI.alert(viewController: self, desc: str)
                }, completionHandler: { (id) in
                    self.close(withID: id)
                })
            } else {
                ServiceAPI.alert(viewController: self, desc: "Пожалуйста, введите имя группы")
            }
        }
    }

}
