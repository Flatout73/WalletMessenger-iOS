//
//  ContactTableViewController.swift
//  WalletHakathon
//
//  Created by Андрей on 29.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit
import Contacts

class ContactTableViewController: UITableViewController {

    var contact = CNContact()
    var phones:[String: Int] = [:] //0 - незагружено, -1 - отсутствует в базе, 1 - можно писать
    var count = 0
    var downloaded = 0
    var IDs = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        count = contact.phoneNumbers.count
        
        for phone in contact.phoneNumbers {
            phones[phone.value.stringValue] = 0
            ServiceAPI.getByPhone(phoneNumber: phone.value.stringValue, noncompletedHandler: {[weak self] (str) in
                if let this = self {
                    this.phones[phone.value.stringValue] = -1
                    this.downloaded += 1
                    
                    if(this.downloaded == this.count){
                        DispatchQueue.main.async {[weak self] in
                            self?.tableView.reloadData()
                        }
                    }
                }

            }, completionHandler: {[weak self] in
                if let this = self {
                    this.phones[phone.value.stringValue] = 11
                    this.downloaded += 1
                    
                    if(this.downloaded == this.count){
                        DispatchQueue.main.async {[weak self] in
                            self?.tableView.reloadData()
                        }
                    }
                }
                
            })
        }
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(downloaded == count){
            return count
        }
        
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
            
            if let data = contact.imageData{
                cell.userImageView.image = UIImage(data: data)
            } else {
                cell.userImageView.image = UIImage(named: "no_photo")
            }
        
            cell.userNameLabel.text = "\(contact.givenName) \(contact.familyName)"
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "phoneCell", for: indexPath)
            
            cell.textLabel?.text = contact.phoneNumbers[indexPath.row - 1].label
            cell.detailTextLabel?.text = contact.phoneNumbers[indexPath.row - 1].value.stringValue
            
            if(phones[contact.phoneNumbers[indexPath.row - 1].value.stringValue] == 1){
                cell.accessoryType = .disclosureIndicator
            }
            
            return cell
        }

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(phones[contact.phoneNumbers[indexPath.row - 1].value.stringValue] == 1){
            ServiceAPI.createDialog(coreDataService: <#T##CoreDataService#>, phoneNumber: <#T##String#>, noncompletedHandler: <#T##(String) -> Void#>, completionHandler: <#T##() -> Void#>)
            
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
