//
//  ContactsTableViewController.swift
//  WalletHakathon
//
//  Created by Андрей on 29.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit
import Contacts

class ContactsTableViewController: UITableViewController, DialogDelegateCaller, GroupDelegateCaller {
    
    func callDialogDelegate(withDialogID: Int) {
        dialogDelegate?.openDialog(withID: withDialogID)
    }

    func callGroupDelegate(withGroupID: Int) {
        groupDelegate?.openDialog(withID: withGroupID)
    }

    var dialogDelegate: ContactDialogDelegate?
    var groupDelegate: ContactGroupDelegate?
    
    var contacts = [CNContact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(self.close))
        
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .denied || status == .restricted {
            presentSettingsActionSheet()
            return
        }
        
        // open it
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            guard granted else {
                DispatchQueue.main.async {
                    self.presentSettingsActionSheet()
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
    
    func close(){
        _ = navigationController?.popToRootViewController(animated: false)
        navigationController?.viewControllers.first?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count + 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell", for: indexPath)
            
            cell.textLabel?.text = "Создать беседу"
            
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell", for: indexPath)
            
            cell.textLabel?.text = "Написать человеку не из контактов"
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)

            let contact = contacts[indexPath.row - 2]
            cell.textLabel?.text = "\(contact.givenName) \(contact.familyName)"
            
            return cell
        }

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0){
            self.performSegue(withIdentifier: "makeGroup", sender: nil)
        } else if(indexPath.row == 1){
            self.performSegue(withIdentifier: "writeSmbd", sender: nil)
        } else {
            self.performSegue(withIdentifier: "showUser", sender: indexPath.row - 2)
        }
        
    }
    
    func presentSettingsActionSheet() {
        let alert = UIAlertController(title: "Permission to Contacts", message: "This app needs access to contacts in order to ...", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default) { _ in
            let url = URL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.shared.open(url)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ContactTableViewController, let num = sender as? Int{
            vc.contact = contacts[num]
        }
    }
 

}

protocol ContactDialogDelegate {
    func openDialog(withID: Int)
}

protocol ContactGroupDelegate {
    func openDialog(withID: Int)
}

protocol DialogDelegateCaller {
    func callDialogDelegate(withDialogID: Int)
}

protocol GroupDelegateCaller {
    func callGroupDelegate(withGroupID: Int)
}

