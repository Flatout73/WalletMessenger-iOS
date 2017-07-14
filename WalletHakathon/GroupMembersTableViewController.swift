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

    var groupDelegate: ContactGroupDelegate?
    var root:UIViewController?
    
    var contacts = [CNContact]()
    var cellsChecked:[Int] = []
    var phones:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Далее", style: .done, target: self, action: #selector(self.createGroupVC))
        self.navigationItem.title = "Новая беседа"
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func createGroupVC(){
        if(phones.count > 0){
            self.performSegue(withIdentifier: "createGroup", sender: nil)
        } else {
            ServiceAPI.alert(viewController: self, desc: "Выберите хотя бы 1 пользователя")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactTableViewCell
        
        let contact = contacts[indexPath.row]
        cell.nameLabel.text = "\(contact.givenName) \(contact.familyName)"
        
        if let data = contact.imageData{
            cell.userImageView.image = UIImage(data: data)
        }
        
        if cellsChecked.contains(indexPath.row) {
            cell.accessoryType = .checkmark
            cell.detailTextLabel?.text = phones[cellsChecked.index(of: indexPath.row)!]
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
            let alert = UIAlertController(title: "", message: "Выберите нужный номер телефона", preferredStyle: .actionSheet)
            let contact = contacts[indexPath.row]
            
            
            for phone in contact.phoneNumbers {
                let phoneAction = UIAlertAction(title: StringService.getClearPhone(byString: phone.value.stringValue) , style: .default)
                {[weak self]
                    (action) in
                    if let this = self {
                        if this.phones.contains(action.title!) {
                            this.phones.remove(at: this.phones.index(of: action.title!)! )
                            this.cellsChecked.remove(at: this.cellsChecked.index(of: indexPath.row)!)
                            
                        } else {
                            this.phones.append(action.title!)
                            this.cellsChecked.append(indexPath.row)
                        }
                        DispatchQueue.main.async {
                            if(this.phones.count == 0){
                                this.navigationItem.rightBarButtonItem?.isEnabled = false
                            } else {
                                this.navigationItem.rightBarButtonItem?.isEnabled = true
                            }
                            this.tableView.reloadData()
                        }
                    }
                }
                alert.addAction(phoneAction)
            }
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .default, handler: nil)
            
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
            
            self.tableView.reloadData()
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? GroupCreateTableViewController{
            vc.phones = phones
            vc.groupDelegate = groupDelegate
            vc.root = self
        }
    }
    

}

class UserEntity{
    var name:String = ""
    var phone:Int64 = 0
    var dialogID:Int = 0
}
