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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
