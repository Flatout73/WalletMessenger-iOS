//
//  ParticipantCell.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 02.07.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit

class ParticipantCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var mobilePhone: UILabel!
    
    @IBOutlet weak var admin: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
