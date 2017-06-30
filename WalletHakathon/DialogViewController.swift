//
//  DialogViewController.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 24.06.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit
import CoreData

class DialogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var messeges = ["1234", "5678"]
    
    var fetchedResultsController: NSFetchedResultsController<Transaction>!
    
    var coreDataService = CoreDataService.sharedInstance
    
    var conversation: Conversation!
    var dialogID: Int!
    
    
    var refreshControl: UIRefreshControl!
    
    
    
    @IBOutlet weak var moneyField: UITextField!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var goButton: UIButton!
    

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("id диалога: ", dialogID)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        messeges = messeges.reversed()
        tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi))
        
        
        //for tests
        //coreDataService.insertConversation(userID: 123, conversationID: 45, name: "kek", mobilePhone: 123456, balance: 56.0, avatar: nil)
        
        //dialogID = 45
        //conversation = coreDataService.findConversaionBy(id: 45)
        
        
        fetchedResultsController = coreDataService.getFRCForTransactions(dialogID: dialogID)

        fetchedResultsController.delegate = self
        
        do{
            try fetchedResultsController.performFetch()
        } catch{
            print(error.localizedDescription)
        }
        
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Идет обновлени...")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        refreshControl.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        
        tableView.addSubview(refreshControl)
    }
    
    func refresh(sender: Any) {
        refreshBegin { (x:Int) -> () in
            try! self.fetchedResultsController.performFetch()
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    func refreshBegin(refreshEnd:@escaping (Int) -> ()) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            if let this = self {
                
                ServiceAPI.getDialogInfo(dialogID: this.dialogID, noncompletedHandler: this.errorHandler) {
                    DispatchQueue.main.async {
                        refreshEnd(0)
                    }
                }
            }
        }
    }
    
    func errorHandler(error:String) {
        self.refreshControl.endRefreshing()
        ServiceAPI.alert(viewController: self, title: "Ошибка!", desc: error)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //return 1
        
        if let count = fetchedResultsController.sections?.count {
            return count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return messeges.count
        
        if(!fetchedResultsController.sections!.isEmpty) {
            if let sectionInfo = fetchedResultsController.sections?[section]{
                return sectionInfo.numberOfObjects
            } else {
                print("Unexpected Section")
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        if(indexPath.section % 2 == 0) {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "toMe", for: indexPath) as! MessageTableViewCell
//            
//            if(!cell.isReversed){
//                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
//                cell.isReversed = true
//            }
//        
//            cell.qiwiorNal.image = #imageLiteral(resourceName: "qiwi_logo")
//            cell.sum.text = messeges[indexPath.row] + " руб."
//        
//            return cell
//        } else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "fromMe", for: indexPath) as! MessageTableViewCell
//            
//            if(!cell.isReversed){
//                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
//                cell.isReversed = true
//            }
//
//            cell.qiwiorNal.image = #imageLiteral(resourceName: "qiwi_logo")
//            cell.sum.text = messeges[indexPath.row] + " руб."
//            
//            return cell
//        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "toMe", for: indexPath) as! MessageTableViewCell

        if let section = fetchedResultsController.sections?[0] {
            
            let newIndexPath = IndexPath(row: section.numberOfObjects - indexPath.row - 1, section: indexPath.section)
            let transaction = fetchedResultsController.object(at: newIndexPath)
            
            
            
            
            if(!cell.isReversed){
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                cell.isReversed = true
            }
            
            transaction.managedObjectContext?.performAndWait {
                cell.qiwiorNal.image = #imageLiteral(resourceName: "qiwi_logo")
                cell.sum.text = String(transaction.money) + " руб."
            }
        }
        
        return cell

        
    }
    
    var i = 0
    @IBAction func sendMoney(_ sender: Any) {
        
        //messeges.insert("678", at: 0)
        //tableView.reloadData()
        
        
        //ServiceAPI.sendTransaction(dialogID: <#T##Int#>, money: <#T##Double#>, cash: <#T##Bool#>, text: <#T##String?#>, noncompletedHandler: <#T##(String) -> Void#>, completionHandler: <#T##() -> Void#>)
        
//        DispatchQueue.main.async {[weak self] in
//            if let this = self {
//                let indexPath = IndexPath(row: this.messeges.count - 1, section: 0)
//                this.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//            }
//        }
        
        
        showStepper()
    }
    
    func showStepper() {
        tableView.contentInset = UIEdgeInsets(top: 32, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
        
        if(tableView.numberOfRows(inSection: 0) > 0){
            tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        }
        
        moneyField.isHidden = false
        stepper.isHidden = false
        goButton.isHidden = false
    }
    
    @IBAction func stepperChanged(_ sender: Any) {
        
        moneyField.text = Int((sender as! UIStepper).value).description
    }
    
    
    @IBAction func sendMoneyOnServer(_ sender: Any) {
        
        
        conversation = coreDataService.findConversaionBy(id: dialogID)
        
        print(coreDataService.appUser.userID)
        CoreDataService.sharedInstance.insertTransaction(id: 1234, money: Double(12 + i), text: "", date: Date(), isCash: true, conversation: conversation, group: nil, reciver: coreDataService.appUser, sender: coreDataService.appUser)
        
        
        try! fetchedResultsController.performFetch()
        tableView.reloadData()
        
        i+=1
        
        tableView.contentInset = UIEdgeInsets.zero
        tableView.scrollIndicatorInsets = tableView.contentInset
        
        moneyField.isHidden = true
        stepper.isHidden = true
        goButton.isHidden = true
    }
    
    

}


extension DialogViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex),
                                 with: .automatic)
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex),
                                 with: .automatic)
        case .move, .update: break
        }
    }

}
