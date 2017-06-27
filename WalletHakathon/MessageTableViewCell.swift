//
//  MessageTableViewCell.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 25.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var qiwiorNal: UIImageView!
    @IBOutlet weak var sum: UILabel!
    
    var isReversed = true
    
    @IBOutlet weak var messView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messView.layer.borderWidth = 2.0
        messView.layer.cornerRadius = 25
        messView.layer.borderColor = UIColor.white.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
