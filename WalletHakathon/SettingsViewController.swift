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
    
    var nameChanged = false
    var passwordChanged = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tableView.separatorColor = self.tableView.backgroundColor
        
        avatar.layer.masksToBounds = false
        avatar.layer.cornerRadius = avatar.frame.height/2
        avatar.clipsToBounds = true

        nameTextField.delegate = self
        passwordTextField.delegate = self
        
        
        //imageCell.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "no_photo"))
    
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let text = textField.text,
            text != "",
            text.characters.count > 5{
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
        if(textField == self.nameTextField){
            nameChanged = true
        } else {
            passwordChanged = true
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
