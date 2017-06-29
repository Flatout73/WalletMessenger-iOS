//
//  RegistrViewController.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 26.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit

class RegistrViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var numberTF: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberTF.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendSMSForRegistration(_ sender: Any) {
        
        let alert = UIAlertController(title: "Смс отправлено!", message: "Введите код из СМС", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "1234"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self, alert] (_) in
            let textField = alert.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(textField.text)")
            
            if(textField.text != "1234") {
                self?.errorLabel.text = "Неверный код"
                self?.errorLabel.isHidden = false
            }
            else {
                self?.errorLabel.text = "Код подтвержден"
                self?.performSegue(withIdentifier: "addInfo", sender: self)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? InfoRegistViewController {
            vc.numberTF = Int(numberTF.text!)
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
