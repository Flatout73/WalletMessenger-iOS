//
//  ChatTableViewCell.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 24.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var balance: UILabel!
    
    @IBOutlet weak var mobilePhone: UILabel!
    
    
    var dialogID: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatar.layer.borderWidth = 1
        avatar.layer.masksToBounds = false
        avatar.layer.borderColor = UIColor.white.cgColor
        avatar.layer.cornerRadius = avatar.frame.height/2
        avatar.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
