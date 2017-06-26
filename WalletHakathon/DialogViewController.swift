//
//  DialogViewController.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 24.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit

class DialogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var messeges = ["1234", "5678"]

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        messeges = messeges.reversed()
        tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi));
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return messeges.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "toMe", for: indexPath) as! MessageTableViewCell
            
            cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
        
            cell.qiwiorNal.image = #imageLiteral(resourceName: "qiwi_logo")
            cell.sum.text = messeges[indexPath.section] + " руб."
        
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "fromMe", for: indexPath) as! MessageTableViewCell
            
            cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
            
            cell.qiwiorNal.image = #imageLiteral(resourceName: "qiwi_logo")
            cell.sum.text = messeges[indexPath.section] + " руб."
            
            return cell
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
