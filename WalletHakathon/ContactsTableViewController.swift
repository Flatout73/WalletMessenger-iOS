//
//  ContactsTableViewController.swift
//  WalletHakathon
//
//  Created by Андрей on 29.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit
import Contacts
import MBProgressHUD

class ContactsTableViewController: UITableViewController {

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
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func close(dialogInfo: DialogInfo){
        DispatchQueue.main.async {[weak self] in
            if let this = self{
               MBProgressHUD.hide(for: this.view, animated: true)
            }
            
            _ = self?.navigationController?.popToRootViewController(animated: false)
            self?.dismiss(animated: true, completion: nil)
            self?.dialogDelegate?.openDialog(withDialogInfo: dialogInfo )
        }
    }

    func dism(){
        self.dismiss(animated: true, completion: nil)
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
            
            cell.imageView?.image = #imageLiteral(resourceName: "group")
            cell.textLabel?.text = "Создать беседу"
            
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "actionCell", for: indexPath)
            
            cell.imageView?.image = #imageLiteral(resourceName: "contact")
            cell.textLabel?.text = "Создать диалог"
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactTableViewCell

            let contact = contacts[indexPath.row - 2]
            cell.nameLabel.text = "\(contact.givenName) \(contact.familyName)"
            
            if let data = contact.imageData{
                cell.userImageView.image = UIImage(data: data)
            }
            
            return cell
        }

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == 0){
            self.performSegue(withIdentifier: "makeGroup", sender: nil)
        } else if(indexPath.row == 1){
            self.performSegue(withIdentifier: "writeSMBD", sender: nil)
        } else {
            let alert = UIAlertController(title: "", message: "Выберите нужный номер телефона", preferredStyle: .actionSheet)
            let contact = contacts[indexPath.row - 2]
            
            
            
            for phone in contact.phoneNumbers {
                let phoneAction = UIAlertAction(title: StringService.getClearPhone(byString: phone.value.stringValue) , style: .default, handler: {(action) in
                    
                    let phoneStr = StringService.getClearPhone(byString: action.title!)
                    
                    if let phone = CoreDataService.sharedInstance.mobilePhone, Int64(phoneStr) !=  phone{
                    
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                    ServiceAPI.getByPhone(phoneNumber: phoneStr, noncompletedHandler: {str in ServiceAPI.alert(viewController: self, desc: str)}, completionHandler: { us in
                        ServiceAPI.createDialogWithUser(user: us, noncompletedHandler: {str in ServiceAPI.alert(viewController: self, desc: str)}, completionHandler: { dialogID in
                            let dialogInfo = DialogInfo()
                            dialogInfo.dialogID = dialogID
                            dialogInfo.user = us
                            self.close(dialogInfo: dialogInfo)
                        })
                     })
                    } else {
                        ServiceAPI.alert(viewController: self, desc: "Нельзя выбрать свой номер телефона")
                    }
                })
                alert.addAction(phoneAction)
            }
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .default, handler: nil)
            
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
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
            vc.contacts = contacts
            vc.groupDelegate = groupDelegate
            vc.root = self
        }
    }
 

}

protocol ContactDialogDelegate {
    func openDialog(withDialogInfo: DialogInfo)
}

protocol ContactGroupDelegate {
    func openGroup(withGroupID: Int)
}

