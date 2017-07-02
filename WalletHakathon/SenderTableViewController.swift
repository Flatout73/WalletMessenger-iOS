//
//  SenderTableViewController.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 02.07.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit


class SenderTableViewController: UITableViewController, UITextFieldDelegate, SelectedUserDelegate {
    
    
    @IBOutlet weak var moneyField: UITextField!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var okButton: UIBarButtonItem!
    
    @IBOutlet weak var nameReceiver: UILabel!
    
    var reciverID = 0
    var Nal: Bool = true
    
    var groupId: Int!
    
    var delegate: TableViewUpdateDelegate!
    
    var phoneOfReceiver: Int64?
    
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
            
            if(true/*&& reciverID != 0*/) {
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
            
            ServiceAPI.sendMoneyQiwi(phoneToSend: phoneOfReceiver!, summa: Double(moneyField.text!)!, transactionID: transactionQiwiID, noncomplitedHandler: errorHandler) {
                
                ServiceAPI.groupSendTransaction(receiverID: self.reciverID, groupID: self.groupId, money: money, cash: self.Nal, text: self.textField.text == "" ? "hey" : self.textField.text, noncompletedHandler: self.errorHandler) {
                    
                    DispatchQueue.main.async {
                       self.navigationController?.popViewController(animated: true)
                       self.delegate.update()
                    }
                    
                }
            }
        } else {
            
            ServiceAPI.groupSendTransaction(receiverID: reciverID, groupID: groupId, money: money, cash: Nal, text: textField.text == "" ? "hey" : textField.text, noncompletedHandler: self.errorHandler) {
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                    self.delegate.update()
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
