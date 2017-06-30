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

    var phones:[String] = []
    
    func close(){
        _ = navigationController?.popToRootViewController(animated: false)
        navigationController?.viewControllers.first?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 1){
            //ServiceAPI.createGroup
            //Крутится колесо, close()
        }
    }

}
