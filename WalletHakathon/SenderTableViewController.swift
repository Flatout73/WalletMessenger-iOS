//
//  SenderTableViewController.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 02.07.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit
import MBProgressHUD

protocol UpdateTable{
    func updateTableForTransactions()
}

class SenderTableViewController: UITableViewController, UITextFieldDelegate, SelectedUserDelegate {
    
    
    @IBOutlet weak var moneyField: UITextField!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var okButton: UIBarButtonItem!
    
    @IBOutlet weak var nameReceiver: UILabel!
    
    var reciverID = 0
    var Nal: Bool = true
    
    var groupId: Int!
    
    var delegate: UpdateTable!
    
    var phoneOfReceiver: Int64?
    
    var amIadmin = false
    
    func didSelect(user: User) {
        nameReceiver.text = user.name
        let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0))
        cell?.accessoryType = .checkmark
        
        let cell2 = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        cell2?.accessoryType = .none
        
        reciverID = Int(user.userID)
            
        phoneOfReceiver = user.mobilePhone
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        textField.delegate = self
        moneyField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath == IndexPath(row: 0, section: 2)) { //способ оплаты
            
            let cell2 = tableView.cellForRow(at: IndexPath(row: 1, section: 2))!
            if(cell2.accessoryType == .checkmark){
                cell2.accessoryType = .none
            }
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
            Nal = true
            
        } else if (indexPath == IndexPath(row: 1, section: 2)) {
            
            if(reciverID != 0) {
                let cell2 = tableView.cellForRow(at: IndexPath(row: 0, section: 2))!
                if(cell2.accessoryType == .checkmark){
                    
                    cell2.accessoryType = .none
                }
                
                let cell = tableView.cellForRow(at: indexPath)
                cell?.accessoryType = .checkmark
                Nal = false
            }
            
        } else if (indexPath == IndexPath(row: 0, section: 3)) { //отправка денег
            if(moneyField.text != "") {
                sendMoney(money: Double(moneyField.text!)!)
            }
        } else if (indexPath == IndexPath(row: 0, section: 0)) {
            let cell2 = tableView.cellForRow(at: IndexPath(row: 1, section: 0))
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
            
            cell?.accessoryType = .checkmark
            cell2?.accessoryType = .disclosureIndicator
            
            reciverID = 0
        }
    }

    var transactionQiwiID = Int64(Date().timeIntervalSince1970)
    func sendMoney(money: Double) {
        if(!Nal){
            MBProgressHUD.showAdded(to: self.view, animated: true)
            ServiceAPI.sendMoneyQiwi(phoneToSend: phoneOfReceiver!, summa: Double(moneyField.text!)!, transactionID: transactionQiwiID, noncomplitedHandler: errorHandler) {
                
                ServiceAPI.groupSendTransaction(receiverID: self.reciverID, groupID: self.groupId, money: money, cash: self.Nal, proof: 1, text: self.textField.text == "" ? "Нет текста" : self.textField.text, noncompletedHandler: self.errorHandler) {
                    
                    DispatchQueue.main.async {
                       MBProgressHUD.hide(for: self.view, animated: true)
                       self.navigationController?.popViewController(animated: true)
                       self.delegate.updateTableForTransactions()
                    }
                    
                }
            }
        } else {
            var proof = 0
            if(amIadmin && reciverID == 0) {
                proof = 1
            }
            
            ServiceAPI.groupSendTransaction(receiverID: reciverID, groupID: groupId, money: money, cash: Nal, proof: proof, text: textField.text == "" ? "Нет текста" : textField.text, noncompletedHandler: self.errorHandler) {
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.navigationController?.popViewController(animated: true)
                    self.delegate.updateTableForTransactions()
                }
            }
        }
    }
    
    func errorHandler(error: String){
        ServiceAPI.alert(viewController: self, desc: error)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        okButton.isEnabled = true
        return true
    }
    
    @IBAction func done(_ sender: Any) {
        self.view.endEditing(true)
        okButton.isEnabled = false
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? RecieverTableViewController {
            vc.groupID = groupId
            vc.delegate = self
        }
    }
 

}
