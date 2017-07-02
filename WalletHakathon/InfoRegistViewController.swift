//
//  InfoRegistViewController.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 27.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit
import MBProgressHUD

class InfoRegistViewController: UIViewController {

    
    var numberTF: Int?
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func registrate(_ sender: Any) {
        
        guard let name = nameField.text, let psw = passwordField.text else {
            
                let alert = UIAlertController(title: "Ошибка!", message: "Введите имя и пароль.", preferredStyle: .alert)
            
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
                self.present(alert, animated: true, completion: nil)
            
            return
            
        }
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        ServiceAPI.registerUser(phone: String(numberTF!), name: name, password: psw, noncompletedHandler: errorHandler) {
            
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                
                let alert = UIAlertController(title: "Успех!", message: "Пользователь успешно зарегистрирован", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default) { (action) in
                    self.performSegue(withIdentifier: "registered", sender: self)
                })
                
                self.present(alert, animated: true, completion: nil)
            }
            
        }
    }
    
    func errorHandler(error: String) {
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Ошибка!", message: error, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        //self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
        
        self.performSegue(withIdentifier: "backToLogin", sender: self)
    }
    

}
