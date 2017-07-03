//
//  SettingsViewController.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 29.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit
import MBProgressHUD

class SettingsViewController: UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    
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
    
    @IBAction func endEditing(_ sender: UITextField) { }
    
    override func viewWillAppear(_ animated: Bool) {
        let coreDataService = CoreDataService.sharedInstance
        
        coreDataService.container.viewContext.performAndWait {
            let appUser = coreDataService.getAppUser(in: coreDataService.container.viewContext)
            
            self.nameTextField.text = appUser.name
            if let image = appUser.avatar as Data? {
                self.avatar.image = UIImage.init(data: image)
            }
        }
    }
    
    func doneButton(){
        if(nameChanged){
            MBProgressHUD.showAdded(to: self.view, animated: true)
            ServiceAPI.changeName(name: nameTextField.text!, completedHandler: {
                DispatchQueue.main.async {
                     MBProgressHUD.hide(for: self.view, animated: true)
                }
               
            }, noncompletedHandler: {str in
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    ServiceAPI.alert(viewController: self, desc: str)
                }
            })
        }
        
        if(passwordChanged){
            MBProgressHUD.showAdded(to: self.view, animated: true)
            ServiceAPI.changePsd(last: lastPasswordTextField.text!, new: passwordTextField.text!, completedHandler: {
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                
            }, noncompletedHandler: {str in
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                    ServiceAPI.alert(viewController: self, desc: str)
                }
                
            })
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
        if(indexPath == IndexPath(row: 1, section: 3))
        {
            exit()
        } else if indexPath == IndexPath(row: 0, section:0){
            imageTapped()
        }
    }

    func imageTapped() {
        let choosingController = UIAlertController(title: "Загрузить фото из:", message: nil, preferredStyle: .actionSheet);
        
        let photoAction = UIAlertAction(title: "Камера", style: .default) { (alert) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .camera;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        let libraryAction = UIAlertAction(title: "Фотопленка", style: .default) { (alert) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary;
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        choosingController.addAction(photoAction)
        choosingController.addAction(libraryAction)
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        
        choosingController.addAction(cancelAction)
        self.present(choosingController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        let cancelController = UIAlertController(title: "Фото не было выбрано", message: nil, preferredStyle: .alert);
        let cancelAction = UIAlertAction(title: "Хорошо", style: .cancel)
        cancelController.addAction(cancelAction)
        self.present(cancelController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        
        if let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            let destinationSize = CGSize(width: 100, height: 100)
            UIGraphicsBeginImageContext(destinationSize);
            selectedImage.draw(in: CGRect(x: 0, y: 0, width: destinationSize.width, height: destinationSize.height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();


            if let data = UIImagePNGRepresentation(newImage!) {
                

                MBProgressHUD.showAdded(to: self.view, animated: true)
                ServiceAPI.changePhoto(photo: data, completedHandler: {
                    DispatchQueue.main.async {[weak self] in
                        if let this = self{
                            MBProgressHUD.hide(for: this.view, animated: true)
                            self?.avatar.image = selectedImage
                        }
                        //self?.viewWillAppear(true)
                    }
                }, noncompletedHandler: {str in
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: self.view, animated: true)
                        ServiceAPI.alert(viewController: self, desc: str)
                    }
                    
                })
            }
        }
        
        DispatchQueue.main.async {[weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
    }

}
