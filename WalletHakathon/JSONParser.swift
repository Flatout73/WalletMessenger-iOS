//
//  JSONParser.swift
//  WalletHakathon
//
//  Created by Андрей on 25.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit
import SwiftyJSON

class JSONParser: NSObject {
    
    static func checkJSONWithDefaultClass(data: Data?, error: Error?, nonCompleteHandler: @escaping(String) -> Void, parseHandler: @escaping(JSON) -> ()) {
        do {
            if (error == nil) {
                if let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: []) {
                    
                    let json = JSON(jsonObject)
                    
                    guard let operationOutput = json["defaultClass"]["operationOutput"].bool else {
                        nonCompleteHandler(json["defaultClass"]["token"].string!)
                        return
                    }
                    
                    if (operationOutput) {
                        parseHandler(json)
                    } else {
                        if let token = json["defaultClass"]["token"].string {
                            nonCompleteHandler(token)
                        } else {
                            nonCompleteHandler("token error")
                        }
                    }
                    
                } else {
                    nonCompleteHandler("Невозможно расшифровать пришедший ответ")
                }
            } else {
                nonCompleteHandler("Отсутствует подключение к интернету")
            }
        } catch {
            nonCompleteHandler(error.localizedDescription)
        }
    }

    
}
