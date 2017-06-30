//
//  GroupMembersTableViewController.swift
//  WalletHakathon
//
//  Created by Андрей on 29.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit
import Contacts

class GroupMembersTableViewController: UITableViewController {

    var contacts = [CNContact]()
    var cellsChecked:[Int] = []
    var phones:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Далее", style: .done, target: self, action: #selector(self.createGroupVC))
    }
    
    func createGroupVC(){
        if(phones.count > 1){
            self.performSegue(withIdentifier: "createGroup", sender: nil)
        } else {
            
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)

        let contact = contacts[indexPath.row]
        cell.textLabel?.text = "\(contact.givenName) \(contact.familyName)"
        
        if let data = contact.imageData{
            cell.imageView?.image = UIImage(data: data)
        }
        
        if cellsChecked.contains(indexPath.row) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if cellsChecked.contains(indexPath.row), let index = cellsChecked.index(where: {return $0 == indexPath.row}) {
            cellsChecked.remove(at: index)
            phones.remove(at: index)
            self.tableView.reloadData()
        } else {
            cellsChecked.append(indexPath.row)
            phones.append((contacts[indexPath.row].phoneNumbers.first?.value.stringValue.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range:nil))!)
            self.tableView.reloadData()
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GroupCreateTableViewController{
            vc.phones = phones
        }
    }
    

}
