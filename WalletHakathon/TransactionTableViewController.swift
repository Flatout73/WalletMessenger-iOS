//
//  TransactionTableViewController.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 06.07.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit

class TransactionTableViewController: UITableViewController {
    
    var transactionID: Int!
    
    @IBOutlet weak var senderName: UILabel!
    @IBOutlet weak var senderPhone: UILabel!
    
    @IBOutlet weak var recieverName: UILabel!
    @IBOutlet weak var reciverPhone: UILabel!
    
    @IBOutlet weak var sum: UILabel!
    @IBOutlet weak var textInfo: UILabel!
    @IBOutlet weak var date: UILabel!
    
    
    var sender: User!
    var reciever: User?
    
    var dateNumber: Date?
    var info: String?
    
    var summa: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()


        senderName.text = sender.name
        senderPhone.text = String(describing: sender.mobilePhone)
        
        if let rec = reciever{
            recieverName.text = rec.name
            reciverPhone.text = String(describing: rec.mobilePhone)
        } else{
            recieverName.text = "Общий счет"
            reciverPhone.text = "Общий счет"
        }
        
        if let dateText = dateNumber{
            date.text = String(describing: dateText)
        }
        textInfo.text = info
        
        sum.text = summa
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
