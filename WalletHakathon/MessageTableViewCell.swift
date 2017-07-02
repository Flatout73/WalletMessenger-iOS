//
//  MessageTableViewCell.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 25.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit

protocol TableViewUpdateDelegate {
    func update()
}

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var qiwiorNal: UIImageView!
    @IBOutlet weak var sum: UILabel!
    
    @IBOutlet weak var acceptButton: UIButton?
    @IBOutlet weak var declineButton: UIButton?
    
    @IBOutlet weak var indicator: UIView!
    
    
    @IBOutlet weak var fromViewToImage: NSLayoutConstraint!
    
    @IBOutlet weak var fromViewToSuperView: NSLayoutConstraint!
    
    var isReversed = false
    
    var delegate: TableViewUpdateDelegate!
    
    var transactionID: Int!
    
    //-1 - Отклонена, 0 - в ожидании, 1 - принята, 2 - Qiwi(нейтральная)
    var needApproved: Int = 2
    
    @IBOutlet weak var messView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messView.layer.borderWidth = 2.0
        messView.layer.cornerRadius = 25
        messView.layer.borderColor = UIColor.white.cgColor
        
        indicator.layer.cornerRadius = indicator.frame.height/2
    }
    
    func makeNeedApproveOrNot(code: Int) {
        needApproved = code
        
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
            indicator.backgroundColor = UIColor.green
        } else {
            indicator.backgroundColor = UIColor.red
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    
    @IBAction func accept(_ sender: Any) {
        
        let button = sender as! UIButton
        
        guard let cell = button.superview?.superview as? MessageTableViewCell else {
            print("Не могу получить ячейку")
            return
        }
        
        ServiceAPI.acceptTransaction(transactionID: cell.transactionID, noncompletedHandler: errorHandler) {
            DispatchQueue.main.async {
                self.hideButtons()
                self.delegate.update()
            }
            
        }
        
        
    }
    
    
    @IBAction func decline(_ sender: Any) {
        
        let button = sender as! UIButton
        
        guard let cell = button.superview?.superview as? MessageTableViewCell else {
            print("Не могу получить ячейку")
            return
        }
        
        ServiceAPI.declineTransaction(transactionID: cell.transactionID, noncompletedHandler: errorHandler) {
            DispatchQueue.main.async {
                self.hideButtons()
                self.delegate.update()
            }
        }
    }
    
    func errorHandler(error: String) {
        print(error)
    }
    
}
