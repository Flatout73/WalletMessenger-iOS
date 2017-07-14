//
//  SendTransactionTableViewController.swift
//  WalletHakathon
//
//  Created by Андрей on 13.07.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit
import MBProgressHUD

class SendTransactionTableViewController: UITableViewController, UITextFieldDelegate{

    @IBOutlet weak var moneyField: UITextField!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var okButton: UIBarButtonItem!
    
    @IBOutlet weak var nameReceiver: UILabel!
    @IBOutlet weak var phoneReceiver: UILabel!
    
    var name = ""
    var phone = ""
    
    var reciverID = 0
    var Nal: Bool = true
    
    var dialogID: Int = 0
    
    var delegate: UpdateTable?
    
    var phoneOfReceiver: Int64?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        moneyField.delegate = self
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

                let cell2 = tableView.cellForRow(at: IndexPath(row: 0, section: 2))!
                if(cell2.accessoryType == .checkmark){
                    cell2.accessoryType = .none
                }
                
                let cell = tableView.cellForRow(at: indexPath)
                cell?.accessoryType = .checkmark
                Nal = false
            
        } else if (indexPath == IndexPath(row: 0, section: 3)) { //отправка денег
            if(moneyField.text != "") {
                sendMoney(money: Double(moneyField.text!)!)
            }
        }
    }
    
    var transactionQiwiID = Int64(Date().timeIntervalSince1970)
    
    func sendMoney(money: Double) {
        if(!Nal){
            MBProgressHUD.showAdded(to: self.view, animated: true)
            ServiceAPI.sendMoneyQiwi(phoneToSend: phoneOfReceiver!, summa: Double(moneyField.text!)!, transactionID: transactionQiwiID, noncomplitedHandler: errorHandler) {
                
                ServiceAPI.sendTransaction(dialogID: self.dialogID, money: money, cash: self.Nal, text: self.textField.text!, noncompletedHandler: self.errorHandler){
                    
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: self.view, animated: true)
                        self.navigationController?.popViewController(animated: true)
                        self.delegate?.updateTableForTransactions()
                    }
                    
                }
            }
        } else {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            
            ServiceAPI.sendTransaction(dialogID: dialogID, money: money, cash: self.Nal, text: self.textField.text!, noncompletedHandler: self.errorHandler){
                
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.navigationController?.popViewController(animated: true)
                    self.delegate?.updateTableForTransactions()
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
    

}
