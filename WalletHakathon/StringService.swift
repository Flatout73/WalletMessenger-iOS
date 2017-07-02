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
        var newphone = phone.replacingOccurrences(of: "-", with: "", options: NSString.CompareOptions.literal, range:nil).replacingOccurrences(of: "(", with: "", options: NSString.CompareOptions.literal, range:nil).replacingOccurrences(of: ")", with: "", options: NSString.CompareOptions.literal, range:nil).replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range:nil)
        
        let first = newphone[newphone.index(newphone.startIndex, offsetBy: 0)...newphone.index(newphone.startIndex, offsetBy: 0)]
        let second = newphone[newphone.index(newphone.startIndex, offsetBy: 1)...newphone.index(newphone.startIndex, offsetBy: newphone.characters.count - 1)]
        
        if(first == "8"){
            return "7"+second
        } else if first == "+" {
            return second
        }
        
        return newphone
    }
    
    static func createPhones(byArray phones: [String])->String{
        var result = ""
        for i in 0..<phones.count-1 {
            result = result + "\(phones[i]),"
        }
        
        return result + phones[phones.count-1]
    }
}

