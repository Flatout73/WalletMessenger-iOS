//
//  CreationViewController.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 28.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit

class CreationViewController: UIViewController {
    
    var coreDataService: CoreDataService!
    
    @IBOutlet weak var numberField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func closeVIew(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func createDialog(_ sender: Any) {
        
        if let number = numberField.text {
            ServiceAPI.createDialog(phoneNumber: String(number), noncompletedHandler: errorHandler) {
                
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
}
