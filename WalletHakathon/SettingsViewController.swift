//
//  SettingsViewController.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 29.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var imageCell: UIView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var lastPasswordTextField: UITextField!
    var nameChanged = false
    var passwordChanged = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tableView.separatorColor = self.tableView.backgroundColor
        
        avatar.layer.masksToBounds = false
        avatar.layer.cornerRadius = avatar.frame.height/2
        avatar.clipsToBounds = true

        
        //imageCell.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "no_photo"))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(self.doneButton))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отменить", style: .plain, target: self, action: #selector(self.cancelButton))
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        self.nameTextField.addTarget(self, action: #selector(self.ed), for: .editingChanged)
        self.passwordTextField.addTarget(self, action: #selector(self.ed2), for: .editingChanged)
    }
    
    func doneButton(){
        if(nameChanged){
            ServiceAPI.changeName(name: nameTextField.text!, completedHandler: {
                //Надо подумать, что тут делать
            }, noncompletedHandler: {_ in})
        }
        
        if(passwordChanged){
            ServiceAPI.changePsd(last: lastPasswordTextField.text!, new: passwordTextField.text!, completedHandler: {
            //Надо подумать, что тут делать
            }, noncompletedHandler: {_ in})
        }
    }
    
    func cancelButton(){
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        self.nameTextField.text = ""
        self.passwordTextField.text = ""
    }
    
    func ed(){
        nameChanged = true
            if let text = nameTextField.text,
                text != "",
                text.characters.count > 5{
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                self.navigationItem.leftBarButtonItem?.isEnabled = true
            } else {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                nameChanged = false
            }
        
        
    }
    
    func ed2(){
                    passwordChanged = true
        if let text = passwordTextField.text,
            text != "",
            text.characters.count > 5{
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.navigationItem.leftBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            passwordChanged = false
        }
        

    }
    
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func exit() {
        
        for key in UserDefaults.standard.dictionaryRepresentation().keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
        CoreDataService.sharedInstance.destroyCoreData()
        
        //self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
        
        
        self.performSegue(withIdentifier: "exit", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath == IndexPath(row: 1, section: 2))
        {
            exit()
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
