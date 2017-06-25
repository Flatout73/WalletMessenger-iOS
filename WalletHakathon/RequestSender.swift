//
//  RequestSender.swift
//  WalletHakathon
//
//  Created by Андрей on 25.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit

class RequestSender: NSObject {

    static func sendRequest(requestString: String, params: Dictionary<String, String>, parseHandler: @escaping(Data?, Error?) -> Void) {
        
        let url = URL(string: requestString)
        
        let request = NSMutableURLRequest()
        request.url = url
        request.httpMethod = "POST"
        request.timeoutInterval = 200
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var result = ""
        for param in params {
            if result != "" {
                result = result + "&" + param.key + "=" + param.value
            } else {
                result = param.key + "=" + param.value
            }
        }
        
        request.httpBody = result.data(using: .utf8)!
        
        let dataTask = URLSession.shared.dataTask(with: request as URLRequest) {
            (dataRecieved, response, error) in
            parseHandler(dataRecieved, error)
        }
        
        dataTask.resume()
    }

    
}
