//
//  JSONParser.swift
//  WalletHakathon
//
//  Created by Андрей on 25.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit

class JSONParser: NSObject {
    
    static func checkJSONWithDefaultClass(data: Data?, error: Error?, nonCompleteHandler: @escaping(String) -> Void, parseHandler: @escaping(Dictionary<String, Any>) -> ()) {
        do {
            if (error == nil) {
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, String> {
                    
                    guard let operationOutput = json["operationOutput"] else {
                        nonCompleteHandler("Невозможно расшифровать пришедший ответ")
                        return
                    }
                    
                    if (Bool(operationOutput))! {
                        parseHandler(json)
                    } else {
                        if let token = json["token"] {
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
