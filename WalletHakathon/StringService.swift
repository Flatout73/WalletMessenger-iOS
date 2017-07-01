//
//  StringService.swift
//  WalletHakathon
//
//  Created by Андрей on 01.07.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit

class StringService: NSObject {

    static func getClearPhone(byString phone: String)->String{
        return phone.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range:nil).replacingOccurrences(of: "(", with: "", options: NSString.CompareOptions.literal, range:nil).replacingOccurrences(of: ")", with: "", options: NSString.CompareOptions.literal, range:nil).replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range:nil)
    }
}
