//
//  ViewController.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 24.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func login(_ sender: Any) {
        
        if let login = loginField.text, let psw = passwordField.text {
            ServiceAPI.loginUser(phone: login, password: psw, noncompletedHandler: errorHandler) {
                DispatchQueue.main.async { [weak self] in
                    if let this = self {
                        this.performSegue(withIdentifier: "loginS", sender: this)
                    }
                }
                
            }
        } else {
            ServiceAPI.alert(viewController: self, title: "Ошибка!", desc: "Введите логин и пароль")
        }
    }
    
    func errorHandler(error: String) {
        ServiceAPI.alert(viewController: self, desc: error)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

