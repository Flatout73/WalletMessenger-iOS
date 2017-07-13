//
//  ParticipantsTableViewController.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 02.07.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit

class ParticipantsTableViewController: UITableViewController {

    var groupID: Int!
    var adminID: Int?
    
    @IBOutlet weak var exitButton: UIButton!
    
    var amIAdmin = false
    var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self

        if(adminID == CoreDataService.sharedInstance.appUserID){
            amIAdmin = true
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if(amIAdmin) {
            exitButton.setTitle("Удалить", for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        users = CoreDataService.sharedInstance.getParticipants(groupID: groupID)
        users.sort { $0.name! < $1.name! }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "participantCell", for: indexPath) as! ParticipantCell

        let user = users[indexPath.row]
        cell.name.text = user.name
        cell.mobilePhone.text = String(user.mobilePhone)
        
        if let avatar = user.avatar {
            cell.avatar.image = UIImage.init(data: avatar as Data)
        }
        
        if(Int(user.userID) == adminID) {
            cell.admin.text = "Admin"
        } else {
            cell.admin.text = ""
        }

        return cell
    }
    

    @IBAction func exitOrDelete(_ sender: Any) {
        
        if(amIAdmin){
            ServiceAPI.groupDelGroup(groupID: groupID, noncompletedHandler: errorHandler) {
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        } else {
            ServiceAPI.groupQuit(groupID: groupID, noncompletedHandler: errorHandler){
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    func errorHandler(error: String){
        ServiceAPI.alert(viewController: self, desc: error)
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

extension ParticipantsTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate{
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return #imageLiteral(resourceName: "chat_logo")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSMutableAttributedString(string: "Нет участников")
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return NSMutableAttributedString(string: "В этой конференции нет участников, зарегистрированных в приложении")
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        return UIColor.white
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }
    
    func isReversed(_ scrollView: UIScrollView) -> Bool {
        return false
    }
}
