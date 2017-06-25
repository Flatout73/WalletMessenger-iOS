//
//  QiwiLoginViewController.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 25.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit

class QiwiLoginViewController: UIViewController {

    @IBOutlet weak var telephoneNumberField: UITextField!
    
    @IBOutlet weak var codeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    var code = ""
    
    @IBAction func getCode(_ sender: Any) {
        if(!telephoneNumberField.text!.isEmpty) {
            var request = URLRequest(url: URL(string: "https://w.qiwi.com/oauth/authorize")!)
            request.httpMethod = "POST"
            let postString = "client_id=qw-fintech&client_secret=Xghj!bkjv64&client-software=qw-fintech-0.0.1&response_type=code&username=\(telephoneNumberField.text!)"
            request.httpBody = postString.data(using: .utf8)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("error=\(error)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response)")
                }
                
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(responseString)")
                
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                
                if let dict = json as? [String: String] {
                    if let c = dict["code"] {
                        DispatchQueue.main.async { [weak self] in
                            if let this = self{
                                this.code = c
                            }
                        }
                        
                    }
                }
            }
            task.resume()
        }
    }
    
   
    @IBAction func enterinQiwi(_ sender: Any) {
        if(!codeField.text!.isEmpty) {
            var request = URLRequest(url: URL(string: "https://w.qiwi.com/oauth/access_token")!)
            request.httpMethod = "POST"
            let postString = "client_id=qw-fintech&client_secret=Xghj!bkjv64&client-software=qw-fintech-0.0.1&grant_type=urn:qiwi:oauth:grant-type:vcode&code=\(code)&vcode=\(codeField.text!)"
            request.httpBody = postString.data(using: .utf8)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("error=\(error)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response)")
                }
                
                let responseString = String(data: data, encoding: .utf8)
                print("responseString = \(responseString)")
                
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                
                if let dict = json as? [String: String] {
                    if let token = dict["access_token"] {
                        DispatchQueue.main.async { [weak self] in
                            if let this = self{
                                UserDefaults.standard.set(token, forKey: "access_token")
                                let alert = UIAlertController(title: "Успех!", message: "Кошелек Qiwi успешно привязан.", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                this.present(alert, animated: true, completion: nil)
                                
                                print("token:", UserDefaults.standard.value(forKey: "access_token"))
                            }
                        }
                        
                    }
                }
            }
            task.resume()
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
