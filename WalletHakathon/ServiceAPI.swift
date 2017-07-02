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


struct UserForSend {
    var userID: Int,
    name: String,
    mobilePhone: Int64,
    balance: Double = 0.0,
    avatar: Data?
}

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
                
                CoreDataService.sharedInstance.createAppUser(phone: Int64(phone)!, name: name, id: userID, avatar: nil)
            } else {
                noncompletedHandler("Неверный JSON")
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
                
                CoreDataService.sharedInstance.createAppUser(phone: Int64(phone)!, name: name, id: userID, avatar: avatar)
            } else {
                noncompletedHandler("Неверный JSON")
                return
            }
            completionHandler()
        }
    }
    
    static func changePsd(last: String, new: String, completedHandler: @escaping() -> Void, noncompletedHandler: @escaping(String) -> Void) {
        if var dictionary = ServiceAPI.loadDictionary() {
            dictionary["last"] = ServiceAPI.md5(last)
            dictionary["new"] = ServiceAPI.md5(new)
            
            let requestStr = serverAddress + "/user/chpsd"
            
            ServiceAPI.getDefaultClassResult(dictionary: dictionary, requestString: requestStr, noncompletedHandler: noncompletedHandler) { (json) in
                
            }
        } else {
            noncompletedHandler("token error")
        }
    }
    
    static func changeName(name: String, completedHandler: @escaping() -> Void, noncompletedHandler: @escaping(String) -> Void) {
        if var dictionary = ServiceAPI.loadDictionary() {
            dictionary["name"] = name
            
            let coreDataService = CoreDataService.sharedInstance
            
            let requestStr = serverAddress + "/user/chname"
            
            ServiceAPI.getDefaultClassResult(dictionary: dictionary, requestString: requestStr, noncompletedHandler: noncompletedHandler) {   (json) in
                
                coreDataService.changeName(name: name)
            }
        } else {
            noncompletedHandler("token error")
        }
    }
    
    //фото тип string пока стоит
    static func changePhoto(photo: Data, completedHandler: @escaping() -> Void, noncompletedHandler: @escaping(String) -> Void) {
        if var dictionary = ServiceAPI.loadDictionary() {
            dictionary["photo"] = photo.base64EncodedString()
            
            let requestStr = serverAddress + "/user/chphoto"
            
            ServiceAPI.getDefaultClassResult(dictionary: dictionary, requestString: requestStr, noncompletedHandler: noncompletedHandler) {
                (json) in
                
                CoreDataService.sharedInstance.changePhoto(photo: photo)
            }
        } else {
            noncompletedHandler("token error")
        }
    }
    
    static func getByPhone(phoneNumber: String, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping(UserForSend) -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["phone"] = phoneNumber
            
            let request = serverAddress + "/user/getubyphn"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                
                guard let userID = json["userID"].int,
                    let name = json["name"].string,
                    let phone = Int64( json["phone"].string!)
                    else {
                        noncompletedHandler("Неверный JSON")
                        return
                }
                
                var avatar: Data? = nil
                if let image = json["image"].string {
                    avatar = Data(base64Encoded: image)
                }
                
                var us = UserForSend(userID: userID, name: name, mobilePhone: phone, balance: 0, avatar: avatar)
                
            
                completionHandler(us)
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
                        coreDataService.insertConversation(userID: userID, conversationID: conversationID, date: Date(), name: name, mobilePhone: Int64(mobilePhone), balance: balance, avatar: avatar) {
                            completionHandler()
                        }
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
                
                let count = dialogs.count
                for (index, subJSON): (String, JSON) in dialogs {
                    print(subJSON)
                    
                    let user = subJSON["userProfile"]
                    
                    guard
                        let dateLong = subJSON["date"].int64, //тип проверить (Long)
                        let conversationID = subJSON["dialogID"].int,
                        let balance = subJSON["balance"].double,
                        let name = user["name"].string,
                        let userID = user["userID"].int,
                        let phone = user["phone"].string else {
                            noncompletedHandler("Неверный JSON")
                            return
                    }
                    
                    var avatar:Data?
                    
                    if let image = user["image"].string {
                        avatar = Data(base64Encoded: image)
                    }
                    let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                    
                    
                    if let mobilePhone = Int64(phone) {
                        CoreDataService.sharedInstance.insertConversation(userID: userID, conversationID: conversationID, date: date, name: name, mobilePhone: mobilePhone, balance: balance, avatar: avatar) {
                            completionHandler()
                        }
                    } else {
                        noncompletedHandler("Не удалось спарсить мобильный телефон")
                    }
                }
                if(count == 0){
                    completionHandler()
                }
            }
        }
    }
    
    static func getGroups(noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            
            let request = serverAddress + "/conv/getgroups"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                let groups = json["groups"]
                
                let count = groups.count
                for (index, subJSON): (String, JSON) in groups {
                    print(subJSON)
                    
                    guard
                        let name = subJSON["name"].string,
                        let dateLong = subJSON["date"].int64, //тип проверить (Long)
                        let groupID = subJSON["groupID"].int,
                        let sum = subJSON["sum"].double,
                        let balance = subJSON["myBalance"].double,
                        let admin = subJSON["adminID"].int else {
                            noncompletedHandler("Неверный формат JSON")
                            return
                    }
                    let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                    
                    CoreDataService.sharedInstance.insertGroup(groupID: groupID, name: name, date: date, summa: sum, myBalance: balance, adminID: admin) {
                        completionHandler()
                    }
                    
                }
                
                if(count == 0){
                    completionHandler()
                }
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
                
                let count = dialogs.count
                for (index, subJSON): (String, JSON) in dialogs {
                    print(subJSON)
                    
                    let user = subJSON["userProfile"]
                    
                    guard
                        let dateLong = subJSON["date"].int64, //тип проверить (Long)
                        let conversationID = subJSON["dialogID"].int,
                        let balance = subJSON["balance"].double,
                        let name = user["name"].string,
                        let userID = user["userID"].int,
                        let phone = user["phone"].string else {
                            noncompletedHandler("Неверный JSON")
                            return
                    }
                    
                    var avatar: Data?
                    
                    if let image = user["image"].string{
                        avatar = Data(base64Encoded: image)
                    }
                    let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                
                    
                    if let mobilePhone = Int64(phone) {
                        CoreDataService.sharedInstance.insertConversation(userID: userID, conversationID: conversationID, date: date, name: name, mobilePhone: mobilePhone, balance: balance, avatar: avatar) {
                            completionHandler()
                        }
                    } else {
                        noncompletedHandler("Неверный формат мобильного телефона")
                    }
                }
                if(count == 0){
                    completionHandler()
                }
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
                
                let count = groups.count
                for (index, subJSON): (String, JSON) in groups {
                    print(subJSON)
                    
                    guard
                        let name = subJSON["name"].string,
                        let dateLong = subJSON["date"].int64, //тип проверить (Long)
                        let groupID = subJSON["groupID"].int,
                        let sum = subJSON["sum"].double,
                        let balance = subJSON["myBalance"].double,
                        let admin = subJSON["adminID"].int else {
                            noncompletedHandler("Неверный формат JSON")
                            return
                    }
                    let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                    
                    CoreDataService.sharedInstance.insertGroup(groupID: groupID, name: name, date: date, summa: sum, myBalance: balance, adminID: admin) {
                        completionHandler()
                    }
                }
                
                if(count == 0){
                    completionHandler()
                }
            }
        }
    }
    
    //надо добавить айдти конверсейшена //вроде не надо
    
    //подтверждение транзакций
    static func acceptTransaction(transactionID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["transactionID"] = String(transactionID)
            
            let request = serverAddress + "/conv/accepttr"
            
            
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                
                CoreDataService.sharedInstance.acceptTransactionOrNot(id: transactionID, accept: 1) {
                    completionHandler()
                }
            }
        }
    }
    
    static func declineTransaction(transactionID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["transactionID"] = String(transactionID)
            
            let request = serverAddress + "/conv/declinetr"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                
                CoreDataService.sharedInstance.acceptTransactionOrNot(id: transactionID, accept: -1) {
                    completionHandler()
                }
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
                
                let count = transactions.count
                
                coreDataService.clearK()
                for (index, subJSON): (String, JSON) in transactions {
                    
                    guard
                        let text = subJSON["text"].string,
                        let dateLong = subJSON["date"].int64,
                        let cash = subJSON["cash"].int,
                        let proof = subJSON["proof"].int,
                        let money = subJSON["money"].double,
                        let userID = subJSON["userID"].int,
                        let receiverID = subJSON["receiverID"].int,
                        let transactionID = subJSON["transactionID"].int else {
                            noncompletedHandler("Неверный формат JSON")
                            return
                    }
                    
                    let cashb = (cash > 0)
                    let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                    
                    //let user = coreDataService.findUserBy(id: userID)
                    //let conversation = coreDataService.findConversaionBy(id: dialogID)
                    
                    
                    //coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cashb, proof: proof, conversation: dialogID, group: nil, userID: userID, count: count) {
                    //completionHandler()
                    //}
                    
                    
                    //поправит это
                    coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cashb, proof: proof, conversation: dialogID, group: nil, userID: userID, count: count){
                        completionHandler()
                    }
                    
                    coreDataService.incrementK()
                    
                }
                if(count == 0){
                    completionHandler()
                }
            }
        }
    }
    
        static func sendTransaction(dialogID: Int, money: Double, cash: Bool, text: String?, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
            
            if var dicionary = loadDictionary() {
                dicionary["dialogID"] = String(dialogID)
                dicionary["money"] = String(money)
                dicionary["cash"] = cash ? "1" : "0"
                dicionary["text"] = text ?? ""
                
                let request = serverAddress + "/dialog/sendtr"
                
                CoreDataService.sharedInstance.clearK()
                ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                    
                    guard let dateLong = json["date"].int64,
                        let transactionID = json["id"].int else {
                            noncompletedHandler("Неверный формат JSON")
                            return
                    }
                    let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                    
                    let conversation = CoreDataService.sharedInstance.findConversaionBy(id: dialogID)
                    let user = conversation?.participant
                    
                    
                    
                    CoreDataService.sharedInstance.insertTransaction(id: transactionID, money: money, text: text ?? "", date: date, isCash: cash, proof: 0, conversation: dialogID, group: nil, reciver: Int(user!.userID), sender: Int(CoreDataService.sharedInstance.appUserID)) {
                        completionHandler()
                    }
                    
                    //completionHandler()
                }
            }
        }
    
    
        static func createDialog(phoneNumber: String, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping(Int) -> Void) {
            
            let coreDataService = CoreDataService.sharedInstance
            
            if var dicionary = loadDictionary() {
                dicionary["phone"] = phoneNumber
                
                let request = serverAddress + "/dialog/create"
                
                let requestPhone = serverAddress + "/user/getubyphn"
                
                ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: requestPhone, noncompletedHandler: noncompletedHandler) { (json) in
                    
                    guard let name = json["name"].string,
                        let phoneStr = json["phone"].string,
                        let phone = Int64(phoneStr),
                        let userID = json["userID"].int else {
                            noncompletedHandler("Неверный формат JSON")
                            return
                    }
                    
                    var avatar: Data? = nil
                    if let image = json["image"].string {
                        avatar = Data(base64Encoded: image)
                    }
                    
                    ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                        
                        guard let dateLong = json["date"].int64,
                        let conversationID = json["id"].int else {
                            noncompletedHandler("Неверный формат JSON")
                            return
                        }
                        let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                        coreDataService.insertConversation(userID: userID, conversationID: conversationID, date: date, name: name, mobilePhone: phone, balance: 0.0, avatar: avatar) {
                            completionHandler(conversationID)
                        }
                        
                        //completionHandler(conversationID)
                    }
                    
                }
                
                
            }
            
        }
        
        //без получения юзера по телефону (телефон сюда как Int64 или сразу String)
        //походу лучше вообще весь профиль подавать (тип UserProfile), insertConversation куча данных надо..
    static func createDialogWithUser(/*phone: Int64,*/ user: UserForSend, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping(Int) -> Void) {
            
            let coreDataService = CoreDataService.sharedInstance
            
            if var dicionary = loadDictionary() {
                dicionary["phone"] = String(user.mobilePhone)
                
                let request = serverAddress + "/dialog/create"
                
                ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                    guard let dateLong = json["date"].int64,
                        let conversationID = json["id"].int else {
                            noncompletedHandler("Не удалось распознать JSON")
                            return
                    }
                    
                    let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                    coreDataService.insertConversation(userID: user.userID, conversationID: conversationID, date: date, name: user.name, mobilePhone: user.mobilePhone, balance: user.balance, avatar: user.avatar) {
                        
                        completionHandler(conversationID)
                    }
                    
                    //completionHandler()
                }
                
            }
        }
    
    //историю транзакций подгрузит
    static func getDialogTransactions(transactionID: Int, dialogID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["transactionID"] = String(transactionID)
            dicionary["dialogID"] = String(dialogID)
            
            let request = serverAddress + "/dialog/gettransactions"
            let coreDataService = CoreDataService.sharedInstance
            
            coreDataService.clearK()
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                let transactions = json["transactions"]
            
                let count = transactions.count
                for (index, subJSON): (String, JSON) in transactions {
                    // receiverID, groupID не получал, они не должны быть нужны тут
                    guard
                        let text = subJSON["text"].string,
                        let dateLong = subJSON["date"].int64,
                        let cashInt = subJSON["cash"].int,
                        let proof = subJSON["proof"].int,
                        let money = subJSON["money"].double,
                        let userID = subJSON["userID"].int,
                        let receiverID = subJSON["receiverID"].int,
                        let transactionID = subJSON["transactionID"].int else {
                            noncompletedHandler("Неверный формат JSON")
                            return
                    }
                    
                    let cash = cashInt > 0
                    let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                    
                    
                    
                    let user = coreDataService.findUserBy(id: userID)
                    //let conversation = coreDataService.findConversaionBy(id: dialogID)
                    
                    
                    coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cash, proof: proof, conversation: dialogID, group: nil, reciver: receiverID, sender: userID, count: count) {
                        completionHandler()
                    }
                    
                    coreDataService.incrementK()
                }
                
                if(count == 0){
                    completionHandler()
                }
            }
        }
    }
    
    
    //новые подгрузит
    static func getNewDialogTransactions(transactionID: Int, dialogID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["transactionID"] = String(transactionID)
            dicionary["dialogID"] = String(dialogID)
            
            let request = serverAddress + "/dialog/getnewtransactions"
            
            let coreDataService = CoreDataService.sharedInstance
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                let transactions = json["transactions"]
                
                let count = transactions.count
                
                coreDataService.clearK()
                for (index, subJSON): (String, JSON) in transactions {
                    //receiverID, groupID не получал, они не должны быть нужны тут
                    guard
                        let text = subJSON["text"].string,
                        let dateLong = subJSON["date"].int64,
                        let cashInt = subJSON["cash"].int,
                        let proof = subJSON["proof"].int,
                        let money = subJSON["money"].double,
                        let userID = subJSON["userID"].int,
                        let receiverID = subJSON["receiverID"].int,
                        let transactionID = subJSON["transactionID"].int else {
                            noncompletedHandler("Неверный формат JSON")
                            return
                    }
                    
                    let cash = cashInt > 0
                    let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                    
                    let user = coreDataService.findUserBy(id: userID)
                    //let conversation = coreDataService.findConversaionBy(id: dialogID)
                    
                    coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cash, proof: proof, conversation: dialogID, group: nil, reciver: receiverID, sender: userID, count: count) {
                        completionHandler()
                    }
                    
                    coreDataService.incrementK()
                    
                }
                //completionHandler()
            }
        }
    }
    
    
    //Group Controller
    
    static func getGroupInfo(groupID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["groupID"] = String(groupID)
            
            let request = serverAddress + "/group/get"
            
            let coreDataService = CoreDataService.sharedInstance
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                
                let userprofiles = json["userProfiles"]
                
                //получаем юзеров в группе
                for (index, subJSON): (String, JSON) in userprofiles {
                    
                    guard let userID = subJSON["userID"].int,
                        let balance = subJSON["balance"].double,
                        let name = subJSON["name"].string,
                        let phone = subJSON["phone"].string else {
                            noncompletedHandler("Неверный формат JSON при получении юзеров в группе")
                            return
                    }
                    
                    var avatar: Data?
                    if let image = subJSON["image"].string{
                        avatar = Data(base64Encoded: image)
                    }
                    if let phoneNumber = Int64(phone){
                    
                        coreDataService.insertGroupUsers(groupID: groupID, userID: userID, balance: balance, name: name, phone: phoneNumber, avatar: avatar) {
                            
                        }
                    } else {
                        noncompletedHandler("Неверный номер телефона")
                    }
                    
                }
                
                let transactions = json["transactions"]
                for (index, subJSON): (String, JSON) in transactions {
                    
                    guard
                        let text = subJSON["text"].string,
                        let dateLong = subJSON["date"].int64,
                        let cashInt = subJSON["cash"].int,
                        let proof = subJSON["proof"].int,
                        let money = subJSON["money"].double,
                        let userID = subJSON["userID"].int,
                        let receiverID = subJSON["receiverID"].int,
                        let transactionID = subJSON["transactionID"].int else {
                            noncompletedHandler("Неверный формат JSON")
                            return
                    }
                    
                    let cash = cashInt > 0
                    let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                    
                    //let user = coreDataService.findUserBy(id: userID)
                    //let conversation = coreDataService.findConversaionBy(id: groupID)
                    //здесь сохраняем транзакции для группы
                    //                    if (user?.userID == Int32(userID)) {
                    //                        coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cash, proof: proof, conversation: conversation, group: nil, reciver: conversation?.participant, sender: coreDataService.appUser)
                    //                    } else {
                    //                        coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cash, proof: proof, conversation: conversation, group: nil, reciver: conversation?.participant, sender: coreDataService.appUser)
                    //                    }
                    
                    coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cash, proof: proof, conversation: nil, group: groupID, reciver: receiverID, sender: userID) {
                        completionHandler()
                    }
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
            
            let request = serverAddress + "/group/sendtr"
            
            let coreDataService = CoreDataService.sharedInstance
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                guard let dateLong = json["date"].int64,
                    let transactionID = json["id"].int else {
                        noncompletedHandler("Неверный формат JSON")
                        return
                }
                let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                
                //let conversation = CoreDataService.sharedInstance.findConversaionBy(id: groupID)
                //let user = conversation?.participant
                
                //CoreDataService.sharedInstance.insertTransaction(id: transactionID, money: money, text: text ?? "", date: date, isCash: cash, proof: 0, conversation: conversation, group: nil, reciver: user, sender: CoreDataService.sharedInstance.appUser)
                
                coreDataService.insertTransaction(id: transactionID, money: money, text: text!, date: date, isCash: cash, proof: 0, conversation: nil, group: groupID, reciver: receiverID, sender: coreDataService.appUserID) {
                    completionHandler()
                }
                
                
            }
        }
    }
    
    //История транзакций
    static func getGroupTransactions(groupID: Int, transactionID: Int, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["groupID"] = String(groupID)
            dicionary["transactionID"] = String(transactionID)
            
            let request = serverAddress + "/group/gettransactions"
            let coreDataService = CoreDataService.sharedInstance
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                
                let transactions = json["transactions"]
                for (index, subJSON): (String, JSON) in transactions {
                    guard
                        let text = subJSON["text"].string,
                        let dateLong = subJSON["date"].int64,
                        let cashInt = subJSON["cash"].int,
                        let proof = subJSON["proof"].int,
                        let money = subJSON["money"].double,
                        let userID = subJSON["userID"].int,
                        let receiverID = subJSON["receiverID"].int,
                        let transactionID = subJSON["transactionID"].int else {
                            noncompletedHandler("Неверный формат JSON")
                            return
                    }
                    
                    let cash = cashInt > 0
                    let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                    
                    //userID не получено из JSON (его надо взять после создания группы или из списка
                    //let user = coreDataService.findUserBy(id: userID)
                    //let conversation = coreDataService.findConversaionBy(id: groupID)
                    //хз что тут
                    //                                if (user?.userID == Int32(userID)) {
                    //                                    coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cash, proof: proof, conversation: conversation, group: nil, reciver: conversation?.participant, sender: coreDataService.appUser)
                    //                                } else {
                    //                                    coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cash, proof: proof, conversation: conversation, group: nil, reciver: conversation?.participant, sender: coreDataService.appUser)
                    //                                }
                    
                    coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cash, proof: proof, conversation: nil, group: groupID, reciver: receiverID, sender: userID) {
                        completionHandler()
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
            
            let coreDataService = CoreDataService.sharedInstance
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                let transactions = json["transactions"]
                for (index, subJSON): (String, JSON) in transactions {
                    guard
                        let text = json["text"].string,
                        let dateLong = json["date"].int64,
                        let cashInt = json["cash"].int,
                        let proof = json["proof"].int,
                        let money = json["money"].double,
                        let userID = json["userID"].int,
                        let receiverID = json["receiverID"].int,
                        let transactionID = json["transactionID"].int else {
                            noncompletedHandler("Неверный формат‚ JSON")
                            return
                    }
                    
                    let cash = cashInt > 0
                    let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                    
                    //userID не получено из JSON (его надо взять после создания группы или из списка
                    let user = coreDataService.findUserBy(id: userID)
                    let conversation = coreDataService.findConversaionBy(id: groupID)
                    //хз что тут
                    //                                if (user?.userID == Int32(userID)) {
                    //                                    coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cash, proof: proof, conversation: conversation, group: nil, reciver: conversation?.participant, sender: coreDataService.appUser)
                    //                                } else {
                    //                                    coreDataService.insertTransaction(id: transactionID, money: money, text: text, date: date, isCash: cash, proof: proof, conversation: conversation, group: nil, reciver: conversation?.participant, sender: coreDataService.appUser)
                    //                                }
                }
                completionHandler()
            }
        }
    }
    
    static func createGroup(name: String, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping() -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["name"] = name
            
            let request = serverAddress + "/group/create"
            
            let coreDataService = CoreDataService.sharedInstance
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                guard let dateLong = json["date"].int64,
                    let groupID = json["id"].int else {
                        noncompletedHandler("Неверный формат JSON")
                        return
                }
                let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                
                //let conversation = CoreDataService.sharedInstance.findConversaionBy(id: groupID)
                //let user = conversation?.participant
                
                //CoreDataService.sharedInstance.insertTransaction(id: transactionID, money: money, text: text ?? "", date: Date(timeIntervalSince1970: TimeInterval(date)), isCash: cash, conversation: conversation, group: nil, reciver: user, sender: CoreDataService.sharedInstance.appUser)
                
                coreDataService.insertGroup(groupID: groupID, name: name, date: date, summa: 0, myBalance: 0, adminID: coreDataService.appUserID) {
                    completionHandler()
                }
            }
        }
    }
    
    
    static func createGroupWithUsers(name: String, phones: String, noncompletedHandler: @escaping(String) -> Void, completionHandler: @escaping(Int) -> Void) {
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
                        noncompletedHandler("Неверный формат JSON")
                        return
                }
                let date = Date(timeIntervalSince1970: TimeInterval(dateLong))
                
                let conversation = CoreDataService.sharedInstance.findConversaionBy(id: groupID)
                let user = conversation?.participant
                
                //CoreDataService.sharedInstance.insertTransaction(id: transactionID, money: money, text: text ?? "", date: Date(timeIntervalSince1970: TimeInterval(date)), isCash: cash, conversation: conversation, group: nil, reciver: user, sender: CoreDataService.sharedInstance.appUser)
                
                completionHandler(groupID)
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
    static func groupDelGroup(groupID: Int, noncompletedHandler: @escaping (String) -> Void, completionHandler: @escaping () -> Void) {
        if var dicionary = loadDictionary() {
            dicionary["groupID"] = String(groupID)
            
            //мне тоже ненравится что тут это называется "leave", но переделывать не будем
            let request = serverAddress + "/group/leave"
            
            ServiceAPI.getDefaultClassResult(dictionary: dicionary, requestString: request, noncompletedHandler: noncompletedHandler) { (json) in
                completionHandler()
            }
        }
    }
    
    public static func alert(viewController: UIViewController, title: String = "Ошибка!", desc: String) {
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: title, message: desc, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    
    public static func sendMoneyQiwi(phoneToSend: Int64, summa: Double, transactionID: Int64 = Int64(round(Date().timeIntervalSince1970)), noncomplitedHandler: @escaping (String) -> Void,  complitionHandler: @escaping () -> Void) {
        var request = URLRequest(url: URL(string: "https://sinap.qiwi.com/api/terms/99/payments")!)
        request.httpMethod = "POST"
        
        request.setValue("application/vnd.qiwi.v2+json", forHTTPHeaderField: "Accept")
        request.setValue("gzip, deflate, compress", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("HTTPie/0.3.0", forHTTPHeaderField: "User-Agent")
        
        let token = UserDefaults.standard.string(forKey: "access_token_qiwi")
        if let tok = token{
        
            let phone = String(CoreDataService.sharedInstance.mobilePhone)
            let str = "\(phone):\(tok)"
            let utf8str = str.data(using: String.Encoding.utf8)
        
            let base64 = utf8str?.base64EncodedString()
        
            request.setValue("Token \(base64!)", forHTTPHeaderField: "Authorization")
        } else {
            noncomplitedHandler("Нет токена Qiwi")
            return
        }
        
        let json = [
        "fields" : [
            "account" : String(phoneToSend),
            "prvId" : "99"
        ],
        "id" : String(transactionID),
        "paymentMethod" : [
            "type":"Account",
            "accountId":"643"
        ],
        "sum" : [
            "amount" : Double(summa),
            "currency" : "643"
        ]
    ] as [String : Any]
        
        if let JSONData = try? JSONSerialization.data(withJSONObject: json, options: []) {
            let postString = String(data: JSONData, encoding: .utf8)
            request.httpBody = postString!.data(using: .utf8)
        }
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(error)")
                noncomplitedHandler(error!.localizedDescription)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let json = JSON(data: data)
            
            print(json)
            let transactionInfo = json["transaction"]
            guard let code = transactionInfo["state"]["code"].string else {
                noncomplitedHandler("У пользователя не привязан аккаунт Qiwi к этому номеру")
                return
            }
            
            if(code == "Accepted"){
                complitionHandler()
            } else {
                noncomplitedHandler("Не удалось выполнить операцию: " + code)
            }
        }
        task.resume()

    }

}
