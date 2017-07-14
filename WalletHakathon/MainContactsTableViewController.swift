//
//  MainContactsTableViewController.swift
//  WalletHakathon
//
//  Created by Андрей on 14.07.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit
import Contacts

class MainContactsTableViewController: UITableViewController {

    var dialogDelegate: ContactDialogDelegate?
    var groupDelegate: ContactGroupDelegate?
    
    var contacts = [CNContact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(self.dism))
        self.navigationItem.title = "Новое сообщение"
        
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
        }
    }

    func dism(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell", for: indexPath)
            
            cell.imageView?.image = #imageLiteral(resourceName: "group")
            cell.textLabel?.text = "Создать беседу"
            
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell", for: indexPath)
            
            cell.imageView?.image = #imageLiteral(resourceName: "contact")
            cell.textLabel?.text = "Создать диалог по номеру"
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell", for: indexPath)
            
            cell.imageView?.image = #imageLiteral(resourceName: "contact")
            cell.textLabel?.text = "Создать диалог из контактов"
            
            return cell

        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.row == 0){
            self.performSegue(withIdentifier: "makeGroup", sender: nil)
        } else if(indexPath.row == 1){
            self.performSegue(withIdentifier: "writeSMBD", sender: nil)
        } else {
            self.performSegue(withIdentifier: "openContracts", sender: nil)
        }
    }
    
    func presentSettingsActionSheet() {
        let alert = UIAlertController(title: "Доступ к контактам", message: "Данное приложение требует доступа к контактам", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Открыть настройки", style: .default) { _ in
            let url = URL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.shared.open(url)
        })
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel))
        present(alert, animated: true)
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? WriteSomeBodyTableViewController{
            vc.dialogDelegate = self.dialogDelegate
            vc.groupDelegate = self.groupDelegate
            vc.root = self
        } else if let vc = segue.destination as? GroupMembersTableViewController{
            vc.groupDelegate = groupDelegate
            vc.contacts = self.contacts
            vc.root = self
        } else if let vc = segue.destination as? ContactsTableViewController{
            vc.dialogDelegate = self.dialogDelegate
            vc.root = self
        }
    }
}
