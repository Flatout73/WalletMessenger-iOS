//
//  ServiceAPI.swift
//  WalletHakathon
//
//  Created by РђРЅРґСЂРµР№ on 25.06.17.
//  Copyright В© 2017 HSE. All rights reserved.
//

import UIKit
import SwiftyJSON

let serverAddress = "http://walletmsg.azurewebsites.net/api"
//let serverAddress = "http://localhost:8080"

class ServiceAPI: NSObject {
    
    static func loadDictionary() -> [String: String]? {
        var dictionary: [String: String] = [:]
        
        if let token = UserDefaults.standard.string(forKey: "token") {
            dictionary = ["token": token]
        } else {
            return nil
        }
        return dictionary
    }
    
    static func getDefaultClassResult(dictionary: Dictionary<String, String>, requestString: String, noncompletedHandler: @escaping(String) -> Void, completedParser: @escaping(JSON) -> Void) {
        
        RequestSender.sendRequest(requestString: requestString, params: dictionary) {
            (data, error) in
            JSONParser.checkJSONWithDefaultClass(data: data, error: error, nonCompleteHandler: noncompletedHandler) {
                (json) in
                completedParser(json)
            }
        }
    }
    
    
    static func registerUser(phone: String, name: String, password: String, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        var dictionary: [String: String] = [:]
        dictionary["phone"] = phone
        dictionary["name"] = name
        dictionary["hashpsd"] = md5(password)
        
        let requestStr = serverAddress + "/user/reg"
        
        ServiceAPI.getDefaultClassResult(dictionary: dictionary, requestString: requestStr, noncompletedHandler: noncompletedHandler) { (json) in
            print(json)
            if let token = json["defaultClass"]["token"].string, let userID = json["userID"].int {
                UserDefaults.standard.set(token, forKey: "token")
                UserDefaults.standard.set(userID, forKey: "appUserId")
                
                CoreDataService.sharedInstance.createAppUser(phone: Int(phone)!, name: name, id: userID, avatar: nil)
            }
            
            completionHandler()
        }
    }
    
    static func loginUser(phone: String, password: String, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        var dictionary: [String: String] = [:]
        dictionary["phone"] = phone
        dictionary["hashpsd"] = md5(password)
        
        let requestStr = serverAddress + "/user/log"
        
        ServiceAPI.getDefaultClassResult(dictionary: dictionary, requestString: requestStr, noncompletedHandler: noncompletedHandler) { (json) in
            print(json)
            if let token = json["defaultClass"]["token"].string, let userID = json["userID"].int, let name = json["name"].string {
                UserDefaults.standard.set(token, forKey: "token")
                UserDefaults.standard.set(userID, forKey: "appUserId")
                
                var avatar: Data?
                if let image = json["image"].string {
                    avatar = Data(base64Encoded: image)
                }
                
                CoreDataService.sharedInstance.createAppUser(phone: Int(phone)!, name: name, id: userID, avatar: avatar)
            } else {
                noncompletedHandler("РќРµРІРµСЂРЅС‹Р№ JSON")
                return
            }
            completionHandler()
        }
    }
    
    static func changePsd(last: String, new: String, completedHandler: @escaping() -> Void, noncompletedHandler: @escaping(String) -> Void) {
        if var dictionary = ServiceAPI.loadDictionary() {
            dictionary["last"] = last
            dictionary["new"] = new
            
            let requestStr = serverAddress + "/user/chpsd"
            
            ServiceAPI.getDefaultClassResult(dictionary: dictionary, requestString: requestStr, noncompletedHandler: noncompletedHandler) {
                (json) in
                
                
            }
        } else {
            noncompletedHandler("token error")
        }
    }
    
    static func changeName(name: String, completedHandler: @escaping() -> Void, noncompletedHandler: @escaping(String) -> Void) {
        if var dictionary = ServiceAPI.loadDictionary() {
            dictionary["name"] = name
            
            let requestStr = serverAddress + "/user/chname"
            
            ServiceAPI.getDefaultClassResult(dictionary: dictionary, requestString: requestStr, noncompletedHandler: noncompletedHandler) {
                (json) in
                
                
            }
        } else {
            noncompletedHandler("token error")
        }
    }
    
    //фото тип string пока стоит
    static func changePhoto(photo: String, completedHandler: @escaping() -> Void, noncompletedHandler: @escaping(String) -> Void) {
        if var dictionary = ServiceAPI.loadDictionary() {
            dictionary["photo"] = photo
            
            let requestStr = serverAddress + "/user/chphoto"
            
            ServiceAPI.getDefaultClassResult(dictionary: dictionary, requestString: requestStr, noncompletedHandler: noncompletedHandler) {
                (json) in
                
                
            }
        } else {
            noncompletedHandler("token error")
        }
    }
    
    static func getByPhone(phoneNumber: String, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["phone"] = phoneNumber
            
            let request = serverAddress + "/user/getubyphn"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                
                guard let userID = json["userID"].int,
                    let name = json["name"].string,
                    let phone = json["phone"].string,
                    let image = json["image"].string else {
                        noncompletedHandler("РќРµРІРµСЂРЅС‹Р№ JSON")
                        return
                }
                
                
                
                completionHandler()
            }
        }
    }
    
    private static func md5(_ string: String) -> String {
        
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, string, CC_LONG(string.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate(capacity: 1)
        var hexString = ""
        for byte in digest {
            hexString += String(format: "%02x", byte)
        }
        
        return hexString
    }
    
    //этого метда не будет, используйте код для других
    static func getConversations(noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        
        let coreDataService = CoreDataService.sharedInstance
        
        if let dictionary = loadDictionary() {
            let request = serverAddress + "/conv/gets"
            
            print("Getting conversations")
            
            ServiceAPI.getDefaultClassResult(dictionary: dictionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                
                let dialogs = json["dialogs"]
                
                for (index, subJSON): (String, JSON) in dialogs {
                    print(subJSON)
                    
                    let user = subJSON["userProfile"]
                    
                    guard let conversationID = subJSON["dialogID"].int,
                        let balance = subJSON["balance"].double,
                        let name = user["name"].string,
                        let phone = user["phone"].string,
                        let image = user["image"].string,
                        let userID = user["userID"].int else {
                            noncompletedHandler("РќРµРІРµСЂРЅС‹Р№ JSON")
                            return
                    }
                    
                    let avatar = Data(base64Encoded: image)
                    if let mobilePhone = Int(phone) {
                        coreDataService.insertConversation(userID: userID, conversationID: conversationID, name: name, mobilePhone: mobilePhone, balance: balance, avatar: avatar)
                    } else {
                        noncompletedHandler("РќРµРІРµСЂРЅС‹Р№ С„РѕСЂРјР°С‚ С‚РµР»РµС„РѕРЅР°")
                    }
                }
                
                completionHandler()
            }
        }
    }
    
    //здесь получение диалогов и групп отдельно + история
    
    static func getDialogs(noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            
            let request = serverAddress + "/conv/getdialogs"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                let dialogs = json["dialogs"]
                
                for (index, subJSON): (String, JSON) in dialogs {
                    print(subJSON)
                    
                    let user = subJSON["userProfile"]
                    
                    guard
                        let dateLong = subJSON["date"].int64, //тип проверить (Long)
                        let dialogID = subJSON["dialogID"].int,
                        let balance = subJSON["balance"].double,
                        let name = user["name"].string,
                        let userID = user["userID"].int,
                        let image = user["image"].string,
                        let phone = user["phone"].string else {
                            noncompletedHandler("РќРµРІРµСЂРЅС‹Р№ JSON")
                            return
                    }
                    
                    let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                    let avatar = Data(base64Encoded: image)
                    
                    if let mobilePhone = Int(phone) {
                        coreDataService.insertConversation(userID: userID, conversationID: conversationID, name: name, mobilePhone: mobilePhone, balance: balance, avatar: avatar)
                    } else {
                        noncompletedHandler("РќРµРІРµСЂРЅС‹Р№ С„РѕСЂРјР°С‚ С‚РµР»РµС„РѕРЅР°")
                    }
                }
                completionHandler()
            }
        }
    }
    
    static func getGroups(noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            
            let request = serverAddress + "/conv/getgroups"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                let groups = json["groups"]
                
                for (index, subJSON): (String, JSON) in groups {
                    print(subJSON)
                    
                    guard
                        let name = subJSON["name"].string,
                        let dateLong = subJSON["date"].int64, //тип проверить (Long)
                        let groupID = subJSON["groupID"].int,
                        let sum = subJSON["sum"].int,
                        let balance = subJSON["myBalance"].double,
                        let admin = subJSON["adminID"].int else {
                            noncompletedHandler("РќРµРІРµСЂРЅС‹Р№ JSON")
                            return
                    }
                    let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                    coreDataService.insertConversation(userID: userID, conversationID: conversationID, name: name, mobilePhone: mobilePhone, balance: balance, avatar: avatar)
                }
                completionHandler()
            }
        }
    }
    
    //подгружает более старые диалоги в список диалогов (подавать меньшее значение в date1)
    static func getDialogsHist(date1: Int64, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["date"] = String(date1)
            
            let request = serverAddress + "/conv/gethistdialogs"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                let dialogs = json["dialogs"]
                
                for (index, subJSON): (String, JSON) in dialogs {
                    print(subJSON)
                    
                    let user = subJSON["userProfile"]
                    
                    guard
                        let dateLong = subJSON["date"].int64, //тип проверить (Long)
                        let dialogID = subJSON["dialogID"].int,
                        let balance = subJSON["balance"].double,
                        let name = user["name"].string,
                        let userID = user["userID"].int,
                        let image = user["image"].string,
                        let phone = user["phone"].string else {
                            noncompletedHandler("РќРµРІРµСЂРЅС‹Р№ JSON")
                            return
                    }
                    
                    let avatar = Data(base64Encoded: image)
                    let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                    if let mobilePhone = Int(phone) {
                        coreDataService.insertConversation(userID: userID, conversationID: conversationID, name: name, mobilePhone: mobilePhone, balance: balance, avatar: avatar)
                    } else {
                        noncompletedHandler("РќРµРІРµСЂРЅС‹Р№ С„РѕСЂРјР°С‚ С‚РµР»РµС„РѕРЅР°")
                    }
                }
                completionHandler()
            }
        }
    }
    
    //подгружает более старые группы в список групп (подавать меньшее значение в date1)
    static func getGroupsHist(date1: Int64, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["date"] = String(date1)
            
            let request = serverAddress + "/conv/gethistgroups"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                let groups = json["groups"]
                
                for (index, subJSON): (String, JSON) in groups {
                    print(subJSON)
                    
                    guard
                        let name = subJSON["name"].string,
                        let dateLong = subJSON["date"].int64, //тип проверить (Long)
                        let groupID = subJSON["groupID"].int,
                        let sum = subJSON["sum"].int,
                        let balance = subJSON["myBalance"].double,
                        let admin = subJSON["adminID"].int else {
                            noncompletedHandler("РќРµРІРµСЂРЅС‹Р№ JSON")
                            return
                    }
                    let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                    coreDataService.insertConversation(userID: userID, conversationID: conversationID, name: name, mobilePhone: mobilePhone, balance: balance, avatar: avatar)
                }
                completionHandler()
            }
        }
    }
    
    //подтверждение транзакций
    static func acceptTransaction(transactionID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["transactionID"] = String(transactionID)
            
            let request = serverAddress + "/conv/accepttr"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                completionHandler()
            }
        }
    }
    
    static func declineTransaction(transactionID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["transactionID"] = String(transactionID)
            
            let request = serverAddress + "/conv/declinetr"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                completionHandler()
            }
        }
    }
    
    //Dialog Controller
    
    static func getDialogInfo(dialogID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        
        let coreDataService = CoreDataService.sharedInstance
        
        if var dicionary = loadDictionary() {
            dicionary["dialogID"] = String(dialogID)
            
            let request = serverAddress + "/dialog/get"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                
                let transactions = json["transactions"]
                
                for (index, subJSON): (String, JSON) in transactions {
                    
                    guard
                        let text = json["text"].string,
                        let dateLong = json["date"].int64,
                        let cash = json["cash"].bool,
                        let proof = json["proof"].bool,
                        let money = json["money"].double,
                        let userID = json["userID"].int,
                        let transactionID = json["transactionID"].int else {
                            noncompletedHandler("РќРµРІРµСЂРЅС‹Р№ С„РѕСЂРјР°С‚ JSON")
                            return
                    }
                    
                    let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                    
                    //userID не получено из JSON (его надо взять из создания диалога или получения списка диалогов)
                    let user = coreDataService.findUserBy(id: userID)
                    let conversation = coreDataService.findConversaionBy(id: dialogID)
                    //хз что тут
                    if (user?.userID == Int32(userID)) {
                        coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cash, conversation: conversation, group: nil, reciver: conversation?.participant, sender: coreDataService.appUser)
                    } else {
                        coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cash, conversation: conversation, group: nil, reciver: conversation?.participant, sender: coreDataService.appUser)
                    }
                }
                completionHandler()
            }
        }
        }
        
        static func sendTransaction(dialogID: Int, money: Double, cash: Bool, text: String?, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
            
            if var dicionary = loadDictionary() {
                dicionary["dialogID"] = String(dialogID)
                dicionary["money"] = String(money)
                dicionary["cash"] = cash ? "1":"0"
                dicionary["text"] = text ?? ""
                
                let request = serverAddress + "/dialog/sendtr"
                
                ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                    
                    guard let dateLong = json["date"].int64,
                        let transactionID = json["id"].int else {
                            noncompletedHandler("РќРµРІРµСЂРЅС‹Р№ С„РѕСЂРјР°С‚ JSON")
                            return
                    }
                    let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                    
                    let conversation = CoreDataService.sharedInstance.findConversaionBy(id: dialogID)
                    let user = conversation?.participant
                    
                    CoreDataService.sharedInstance.insertTransaction(id: transactionID, money: money, text: text ?? "", date: Date(timeIntervalSince1970: TimeInterval(date)), isCash: cash, conversation: conversation, group: nil, reciver: user, sender: CoreDataService.sharedInstance.appUser)
                    
                    completionHandler()
                }
            }
        }
        
        static func createDialog(phoneNumber: String, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
            
            let coreDataService = CoreDataService.sharedInstance
            
            if var dicionary = loadDictionary() {
                dicionary["phone"] = phoneNumber
                
                let request = serverAddress + "/dialog/create"
                
                let requestPhone = serverAddress + "/user/getubyphn"
                
                ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: requestPhone, noncompletedHandler: noncompletedHandler) { (json) in
                    
                    guard let name = json["name"].string,
                        let phoneStr = json["phone"].string,
                        let phone = Int(phoneStr),
                        let userID = json["userID"].int else {
                            noncompletedHandler("РќРµРІРµСЂРЅС‹Р№ С„РѕСЂРјР°С‚ JSON")
                            return
                    }
                    
                    var avatar: Data? = nil
                    if let image = json["image"].string {
                        avatar = Data(base64Encoded: image)
                    }
                    
                    ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                        
                        guard let dateLong = json["date"].int64,
                        let conversationID = json["id"].int else {
                            noncompletedHandler("РќРµРІРµСЂРЅС‹Р№ С„РѕСЂРјР°С‚ JSON РїСЂРё СЃРѕР·РґР°РЅРёРё РґРёР°Р»РѕРіР°")
                            return
                        }
                        let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                        coreDataService.insertConversation(userID: userID, conversationID: conversationID, name: name, mobilePhone: phone, balance: 0.0, avatar: avatar)
                        
                        completionHandler()
                    }
                    
                }
                
                
            }
            
        }
        
        //без получения юзера по телефону (телефон сюда как Int64 или сразу String)
        //походу лучше вообще весь профиль подавать (тип UserProfile), insertConversation куча данных надо..
        static func createDialogWithUser(phone: Int64, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
            
            let coreDataService = CoreDataService.sharedInstance
            
            if var dicionary = loadDictionary() {
                dicionary["phone"] = String(phone)
                
                let request = serverAddress + "/dialog/create"
                
                ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                    guard let dateLong = json["date"].int64,
                        let conversationID = json["id"].int else {
                            noncompletedHandler("РќРµРІРµСЂРЅС‹Р№ С„РѕСЂРјР°С‚ JSON РїСЂРё СЃРѕР·РґР°РЅРёРё РґРёР°Р»РѕРіР°")
                            return
                    }
                    let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                    coreDataService.insertConversation(userID: userID, conversationID: conversationID, name: name, mobilePhone: phone, balance: 0.0, avatar: avatar)
                    
                    completionHandler()
                }
                
            }
        }
        
        //историю транзакций подгрузит
        static func getDialogTransactions(transactionID: Int, dialogID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
            if var dicionary = loadDictionary() {
                dicionary["transactionID"] = String(transactionID)
                dicionary["dialogID"] = String(dialogID)
                
                let request = serverAddress + "/dialog/gettransactions"
                
                ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                    let transactions = json["transactions"]
                    
                    for (index, subJSON): (String, JSON) in transactions {
                        //userID, receiverID, groupID не получал, они не должны быть нужны тут
                        guard
                            let text = json["text"].string,
                            let dateLong = json["date"].int64,
                            let cash = json["cash"].bool,
                            let proof = json["proof"].bool,
                            let money = json["money"].double,
                            let transactionID = json["transactionID"].int else {
                                noncompletedHandler("РќРµРІРµСЂРЅС‹Р№ С„РѕСЂРјР°С‚ JSON")
                                return
                        }
                        
                        let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                        
                        //userID не получено из JSON (его надо взять из создания диалога или получения списка диалогов)
                        let user = coreDataService.findUserBy(id: userID)
                        let conversation = coreDataService.findConversaionBy(id: dialogID)
                        //хз что тут
                        if (user?.userID == Int32(userID)) {
                            coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cash, conversation: conversation, group: nil, reciver: conversation?.participant, sender: coreDataService.appUser)
                        } else {
                            coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cash, conversation: conversation, group: nil, reciver: conversation?.participant, sender: coreDataService.appUser)
                        }
                        
                        completionHandler()
                    }
                }
            }
            
            
            //новые подгрузит
            static func getNewDialogTransactions(transactionID: Int, dialogID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
                if var dicionary = loadDictionary() {
                    dicionary["transactionID"] = String(transactionID)
                    dicionary["dialogID"] = String(dialogID)
                    
                    let request = serverAddress + "/dialog/getnewtransactions"
                    
                    ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                        let transactions = json["transactions"]
                        
                        for (index, subJSON): (String, JSON) in transactions {
                            //userID, receiverID, groupID не получал, они не должны быть нужны тут
                            guard
                                let text = json["text"].string,
                                let dateLong = json["date"].int64,
                                let cash = json["cash"].bool,
                                let proof = json["proof"].bool,
                                let money = json["money"].double,
                                let transactionID = json["transactionID"].int else {
                                    noncompletedHandler("РќРµРІРµСЂРЅС‹Р№ С„РѕСЂРјР°С‚ JSON")
                                    return
                            }
                            
                            let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                            
                            //userID не получено из JSON (его надо взять из создания диалога или получения списка диалогов)
                            let user = coreDataService.findUserBy(id: userID)
                            let conversation = coreDataService.findConversaionBy(id: dialogID)
                            //хз что тут
                            if (user?.userID == Int32(userID)) {
                                coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cash, conversation: conversation, group: nil, reciver: conversation?.participant, sender: coreDataService.appUser)
                            } else {
                                coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cash, conversation: conversation, group: nil, reciver: conversation?.participant, sender: coreDataService.appUser)
                            }
                            
                            completionHandler()
                        }
                    }
                }
                
                
                //Group Controller
                
                static func getGroupInfo(groupID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
                    if var dicionary = loadDictionary() {
                        dicionary["groupID"] = String(groupID)
                        
                        let request = serverAddress + "/group/get"
                        
                        ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                            
                            let transactions = json["transactions"]
                            for (index, subJSON): (String, JSON) in transactions {
                                
                                guard
                                    let text = json["text"].string,
                                    let dateLong = json["date"].int64,
                                    let cash = json["cash"].bool,
                                    let proof = json["proof"].bool,
                                    let money = json["money"].double,
                                    let userID = json["userID"].int,
                                    let receiverID = json["receiverID"].int,
                                    let transactionID = json["transactionID"].int else {
                                        noncompletedHandler("РќРµРІРµСЂРЅС‹Р№ С„РѕСЂРјР°С‚ JSON")
                                        return
                                }
                                
                                let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                                
                                //userID не получено из JSON (его надо взять из создания диалога или получения списка диалогов)
                                let user = coreDataService.findUserBy(id: userID)
                                let conversation = coreDataService.findConversaionBy(id: dialogID)
                                //хз что тут
                                if (user?.userID == Int32(userID)) {
                                    coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cash, conversation: conversation, group: nil, reciver: conversation?.participant, sender: coreDataService.appUser)
                                } else {
                                    coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cash, conversation: conversation, group: nil, reciver: conversation?.participant, sender: coreDataService.appUser)
                                }
                            }
                            
                            let userprofiles = json["userProfiles"]
                            
                            for (index, subJSON): (String, JSON) in transactions {
                                
                                guard let userID = json["userID"].int,
                                    let balance = json["balance"].double,
                                    let name = json["name"].string,
                                    let phone = json["phone"].string,
                                    let image = json["image"].string else {
                                        noncompletedHandler("РќРµРІРµСЂРЅС‹Р№ JSON")
                                        return
                                }
                                //куда-нить сохранить надо каждого юзера...
                            }
                            
                            completionHandler()
                        }
                    }
                }
                
                static func groupSendTransaction(receiverID: Int, groupID: Int, money: Double, cash: Bool, text: String?, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
                    if var dicionary = loadDictionary() {
                        dicionary["receiverID"] = String(receiverID)
                        dicionary["groupID"] = String(groupID)
                        dicionary["money"] = String(money)
                        dicionary["cash"] = cash ? "1":"0"
                        dicionary["text"] = text ?? ""
                        
                        let request = serverAddress + "/group/sendtransaction"
                        
                        ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                            guard let dateLong = json["date"].int64,
                                let transactionID = json["id"].int else {
                                    noncompletedHandler("РќРµРІРµСЂРЅС‹Р№ С„РѕСЂРјР°С‚ JSON")
                                    return
                            }
                            let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                            
                            let conversation = CoreDataService.sharedInstance.findConversaionBy(id: dialogID)
                            let user = conversation?.participant
                            
                            CoreDataService.sharedInstance.insertTransaction(id: transactionID, money: money, text: text ?? "", date: Date(timeIntervalSince1970: TimeInterval(date)), isCash: cash, conversation: conversation, group: nil, reciver: user, sender: CoreDataService.sharedInstance.appUser)
                            
                            completionHandler()
                        }
                    }
                }
                
                static func getGroupTransactions(groupID: Int, transactionID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
                    if var dicionary = loadDictionary() {
                        dicionary["groupID"] = String(groupID)
                        dicionary["transactionID"] = String(transactionID)
                        
                        let request = serverAddress + "/group/gettransactions"
                        
                        ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                            let transactions = json["transactions"]
                            for (index, subJSON): (String, JSON) in transactions {
                                guard
                                    let text = json["text"].string,
                                    let dateLong = json["date"].int64,
                                    let cash = json["cash"].bool,
                                    let proof = json["proof"].bool,
                                    let money = json["money"].double,
                                    let userID = json["userID"].int,
                                    let receiverID = json["receiverID"].int,
                                    let transactionID = json["transactionID"].int else {
                                        noncompletedHandler("РќРµРІРµСЂРЅС‹Р№ С„РѕСЂРјР°С‚ JSON")
                                        return
                                }
                                
                                let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                                
                                //userID не получено из JSON (его надо взять после создания группы или из списка
                                let user = coreDataService.findUserBy(id: userID)
                                let conversation = coreDataService.findConversaionBy(id: dialogID)
                                //хз что тут
                                if (user?.userID == Int32(userID)) {
                                    coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cash, conversation: conversation, group: nil, reciver: conversation?.participant, sender: coreDataService.appUser)
                                } else {
                                    coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cash, conversation: conversation, group: nil, reciver: conversation?.participant, sender: coreDataService.appUser)
                                }
                            }
                            completionHandler()
                        }
                    }
                }
                
                static func getNewGroupTransactions(groupID: Int, transactionID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
                    if var dicionary = loadDictionary() {
                        dicionary["groupID"] = String(groupID)
                        dicionary["transactionID"] = String(transactionID)
                        
                        let request = serverAddress + "/group/getnewtransactions"
                        
                        ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                            let transactions = json["transactions"]
                            for (index, subJSON): (String, JSON) in transactions {
                                guard
                                    let text = json["text"].string,
                                    let dateLong = json["date"].int64,
                                    let cash = json["cash"].bool,
                                    let proof = json["proof"].bool,
                                    let money = json["money"].double,
                                    let userID = json["userID"].int,
                                    let receiverID = json["receiverID"].int,
                                    let transactionID = json["transactionID"].int else {
                                        noncompletedHandler("РќРµРІРµСЂРЅС‹Р№ С„РѕСЂРјР°С‚ JSON")
                                        return
                                }
                                
                                let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                                
                                //userID не получено из JSON (его надо взять после создания группы или из списка
                                let user = coreDataService.findUserBy(id: userID)
                                let conversation = coreDataService.findConversaionBy(id: dialogID)
                                //хз что тут
                                if (user?.userID == Int32(userID)) {
                                    coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cash, conversation: conversation, group: nil, reciver: conversation?.participant, sender: coreDataService.appUser)
                                } else {
                                    coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cash, conversation: conversation, group: nil, reciver: conversation?.participant, sender: coreDataService.appUser)
                                }
                            }
                            completionHandler()
                        }
                    }
                }
                
                static func createGroup(name: String, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
                    if var dicionary = loadDictionary() {
                        dicionary["name"] = name
                        
                        let request = serverAddress + "/group/create"
                        
                        ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                            guard let dateLong = json["date"].int64,
                                let groupID = json["id"].int else {
                                    noncompletedHandler("РќРµРІРµСЂРЅС‹Р№ С„РѕСЂРјР°С‚ JSON")
                                    return
                            }
                            let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                            
                            let conversation = CoreDataService.sharedInstance.findConversaionBy(id: dialogID)
                            let user = conversation?.participant
                            
                            CoreDataService.sharedInstance.insertTransaction(id: transactionID, money: money, text: text ?? "", date: Date(timeIntervalSince1970: TimeInterval(date)), isCash: cash, conversation: conversation, group: nil, reciver: user, sender: CoreDataService.sharedInstance.appUser)
                            
                            completionHandler()
                        }
                    }
                }
                
                
                static func createGroupWithUsers(name: String, phones: String, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
                    if var dicionary = loadDictionary() {
                        dicionary["name"] = name
                        dicionary["phones"] = phones
                        
                        //Ещё и сюда напишу на всякий случай про параметр phones 
                        //Очень строгий формат строки! Никаких пробелов вообще! телефоны строго через запятую, в начале и в конце запятых нет: 
                        //Пример: "8913,8150,4444,56774,12312124,0001" - без кавычек соответственно. 
                        
                        let request = serverAddress + "/group/createwithusers"
                        
                        ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                            guard let dateLong = json["date"].int64,
                                let groupID = json["id"].int else {
                                    noncompletedHandler("РќРµРІРµСЂРЅС‹Р№ С„РѕСЂРјР°С‚ JSON")
                                    return
                            }
                            let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                            
                            let conversation = CoreDataService.sharedInstance.findConversaionBy(id: dialogID)
                            let user = conversation?.participant
                            
                            CoreDataService.sharedInstance.insertTransaction(id: transactionID, money: money, text: text ?? "", date: Date(timeIntervalSince1970: TimeInterval(date)), isCash: cash, conversation: conversation, group: nil, reciver: user, sender: CoreDataService.sharedInstance.appUser)
                            
                            completionHandler()
                        }
                    }
                }
                
                //только админ может добавлять (можете(!) сделать ОПЦИОНАЛЬНО)
                //Типо админ в настройках группы устанавливает все могут добавлять или ток он
                //на сервере проверки что это именно "админ" пытается удалить участника из группы нету
                static func groupAddUser(groupID: Int, phone: String, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
                    if var dicionary = loadDictionary() {
                        dicionary["groupID"] = String(groupID)
                        dicionary["phone"] = phone
                        
                        let request = serverAddress + "/group/add"
                        
                        ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                            completionHandler()
                        }
                    }
                }
                
                //только админ может удалять (опять же проверки на сервере что это именно "админ" пытается удалить участника из группы там нет)
                static func groupDelUser(groupID: Int, phone: String, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
                    if var dicionary = loadDictionary() {
                        dicionary["groupID"] = String(groupID)
                        dicionary["phone"] = phone
                        
                        let request = serverAddress + "/group/deluser"
                        
                        ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                            completionHandler()
                        }
                    }
                }
                
                //выйти из беседы самостоятельно
                static func groupQuit(groupID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
                    if var dicionary = loadDictionary() {
                        dicionary["groupID"] = String(groupID)
                        
                        let request = serverAddress + "/group/quit"
                        
                        ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                            completionHandler()
                        }
                    }
                }
                
                //удалить беседу
                static func groupDelGroup(groupID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
                    if var dicionary = loadDictionary() {
                        dicionary["groupID"] = String(groupID)
                        
                        //мне тоже ненравится что тут это называется "leave", но переделывать не будем
                        let request = serverAddress + "/group/leave"
                        
                        ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                            completionHandler()
                        }
                    }
                }
                
                public static func alert(viewController: UIViewController, title: String = "РћС€РёР±РєР°!", desc: String) {
                    DispatchQueue.main.async {
                        
                        let alert = UIAlertController(title: title, message: desc, preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        
                        viewController.present(alert, animated: true, completion: nil)
                    }
                }
                
}
