//
//  MessageTableViewCell.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 25.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit
import MBProgressHUD

protocol TableViewUpdateDelegate {
    func update(index: IndexPath)
}

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var qiwiorNal: UIImageView!
    @IBOutlet weak var sum: UILabel!
    
    @IBOutlet var transText: UILabel!
    @IBOutlet weak var acceptButton: UIButton?
    @IBOutlet weak var declineButton: UIButton?
    
    @IBOutlet weak var indicator: UIView!
    
    @IBOutlet var userPhoto: UIImageView!
    
    @IBOutlet weak var fromViewToImage: NSLayoutConstraint!
    
    @IBOutlet weak var fromViewToSuperView: NSLayoutConstraint!
    
    var isReversed = false
    
    var delegate: TableViewUpdateDelegate!
    
    var transactionID: Int!
    var sender: User?
    var reciever: User?
    var date: Date?
    var textInfo: String?
    
    var cellIndex: IndexPath!
    
    @IBOutlet weak var messView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messView.layer.borderWidth = 2.0
        messView.layer.cornerRadius = messView.frame.width/10
        messView.layer.borderColor = UIColor.white.cgColor
        
        if let acceptButton = acceptButton{
            acceptButton.layer.borderWidth = 1.0
            acceptButton.layer.cornerRadius = acceptButton.frame.width/10
            acceptButton.layer.borderColor = UIColor.white.cgColor
        }

        if let declineButton = declineButton{
            declineButton.layer.borderWidth = 1.0
            declineButton.layer.cornerRadius = declineButton.frame.width/10
            declineButton.layer.borderColor = UIColor.white.cgColor
        }
        
        userPhoto.layer.borderWidth = 1
        userPhoto.layer.masksToBounds = false
        userPhoto.layer.borderColor = UIColor.white.cgColor
        userPhoto.layer.cornerRadius = (userPhoto.frame.height)/2
        userPhoto.clipsToBounds = true
        
        indicator.layer.cornerRadius = indicator.frame.height/2
        
        //loadingIndicator?.hidesWhenStopped = true
    }
    
    func addButtons(){
        if(acceptButton != nil && declineButton != nil){
            self.addSubview(acceptButton!)
            self.addSubview(declineButton!)
        }
    }
    
    func hideButtons() {
        
        if(acceptButton != nil && declineButton != nil){
            acceptButton!.removeFromSuperview()
            declineButton!.removeFromSuperview()
        }
        
    }
    
    func makeIndicator(green: Bool) {
        if(green) {
            indicator.backgroundColor = UIColor.clear
        } else {
            indicator.backgroundColor = UIColor.red
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    
    @IBAction func accept(_ sender: Any) {
        
//        let button = sender as! UIButton
//
//        guard let cell = button.superview?.superview as? MessageTableViewCell else {
//            print("Не могу получить ячейку")
//            return
//        }
//        loadingIndicator?.startAnimating()
        ServiceAPI.acceptTransaction(transactionID: transactionID, noncompletedHandler: errorHandler) {
            DispatchQueue.main.async {
                //self.hideButtons()
//                self.loadingIndicator?.stopAnimating()
                self.delegate.update(index: self.cellIndex)
            }
            
        }
    }
    
    
    @IBAction func decline(_ sender: Any) {
        
//        let button = sender as! UIButton
//
//        guard let cell = button.superview?.superview as? MessageTableViewCell else {
//            print("Не могу получить ячейку")
//            return
//        }
        //loadingIndicator?.startAnimating()
        ServiceAPI.declineTransaction(transactionID: transactionID, noncompletedHandler: errorHandler) {
            DispatchQueue.main.async {
                //self.hideButtons()
                //self.loadingIndicator?.stopAnimating()
                self.delegate.update(index: self.cellIndex)
            }
        }
    }
    
    func errorHandler(error: String) {
        print(error)
    }
    
}
