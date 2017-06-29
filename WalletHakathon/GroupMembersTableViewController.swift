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

        // open it
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            guard granted else {
                DispatchQueue.main.async {
                    
                }
                return
            }
            
            // get the contacts
            
            let request = CNContactFetchRequest(keysToFetch: [CNContactIdentifierKey as NSString, CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactImageDataKey as CNKeyDescriptor])
            do {
                try store.enumerateContacts(with: request) {[weak self] contact, stop in
                    self?.contacts.append(contact)
                }
            } catch {
                print(error)
            }
            
            // do something with the contacts array (e.g. print the names)
            
            let formatter = CNContactFormatter()
            formatter.style = .fullName
            for contact in self.contacts {
                print(formatter.string(from: contact) ?? "???")
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)

        if cellsChecked.contains(indexPath.row) {
            cell.accessoryType = .checkmark
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
            phones.append(contacts[indexPath.row].phoneNumbers.first?.value.stringValue.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range:nil))
            self.tableView.reloadData()
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
