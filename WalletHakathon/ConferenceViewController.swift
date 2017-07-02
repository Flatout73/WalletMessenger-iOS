//
//  ConferenceViewController.swift
//  WalletHakathon
//
//  Created by Леонид Лядвейкин on 02.07.17.
//  Copyright © 2017 HSE. All rights reserved.
//

import UIKit
import CoreData

class ConferenceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TableViewUpdateDelegate, UpdateTable {

    var fetchedResultsController: NSFetchedResultsController<Transaction>!
    
    var coreDataService = CoreDataService.sharedInstance
    
    var groupID: Int!
    var adminID: Int!
    
    var refreshControl: UIRefreshControl!
    
    var loadMoreStatus = false
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func update() {
        DispatchQueue.main.async {
            try? self.fetchedResultsController.performFetch()
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            
        }
        
    }
    
    
    func updateTableForTransactions() {
        DispatchQueue.main.async {
            try? self.fetchedResultsController.performFetch()
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        activityIndicator.hidesWhenStopped = true
        
        tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi))
        
        tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        
        fetchedResultsController = coreDataService.getFRCForTransactions(groupID: groupID)
        
        fetchedResultsController.delegate = self
        
        do{
            try fetchedResultsController.performFetch()
        } catch{
            print(error.localizedDescription)
        }
        
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Идет обновление...")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        refreshControl.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        
        tableView.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refresh(sender: self)
    }

    func refresh(sender: Any) {
        
        if (!loadMoreStatus) {
            self.loadMoreStatus = true
            
            refreshBegin { (x:Int) -> () in
                try? self.fetchedResultsController.performFetch()
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                self.activityIndicator.stopAnimating()
                
                self.loadMoreStatus = false
            }
        } else {
            self.refreshControl.endRefreshing()
        }
    }
    
    func refreshBegin(refreshEnd:@escaping (Int) -> ()) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            if let this = self {
                
                ServiceAPI.getGroupInfo(groupID: this.groupID, noncompletedHandler: this.errorHandler) {
                    DispatchQueue.main.async {
                        refreshEnd(0)
                    }
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        if deltaOffset <= 0 && currentOffset > 0 {
            loadMore()
        }
    }
    
    func loadMore() {
        if (!loadMoreStatus) {
            self.loadMoreStatus = true
            self.activityIndicator.startAnimating()
            self.tableView.tableFooterView?.isHidden = false
            loadMoreBegin(
                loadMoreEnd: {(x:Int) -> () in
                    
                    try! self.fetchedResultsController.performFetch()
                    self.tableView.reloadData()
                    self.loadMoreStatus = false
                    self.activityIndicator.stopAnimating()
                    self.tableView.tableFooterView?.isHidden = true
            })
        }
    }
    
    func loadMoreBegin(loadMoreEnd:@escaping (Int) -> ()) {
        DispatchQueue.global(qos: .utility).async {
            print("loadmore")
            
            try? self.fetchedResultsController.performFetch()
            if(!self.fetchedResultsController.sections!.isEmpty) {
                if let sectionInfo = self.fetchedResultsController.sections?[0]{
                    if (sectionInfo.numberOfObjects > 0) {
                        
                        let trans = self.fetchedResultsController.object(at: IndexPath(row: sectionInfo.numberOfObjects - 1, section: 0))
                        
                        ServiceAPI.getGroupTransactions(groupID: self.groupID, transactionID: Int(trans.transactionID), noncompletedHandler: self.errorHandler){
                            DispatchQueue.main.async  {
                                loadMoreEnd(0)
                            }
                        }
                    } else {
                        ServiceAPI.getGroupInfo(groupID: self.groupID, noncompletedHandler: self.errorHandler){
                            DispatchQueue.main.async  {
                                loadMoreEnd(0)
                            }
                            
                        }
                    }
                    
                }
                
            }
        }
    }
    
    func errorHandler(error:String) {
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
            self.activityIndicator.stopAnimating()
            self.loadMoreStatus = false
            self.tableView.tableFooterView?.isHidden = true
            ServiceAPI.alert(viewController: self, title: "Ошибка!", desc: error)
        }
        
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {

        if let count = fetchedResultsController.sections?.count {
            return count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
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
        
        var cell: MessageTableViewCell
        guard let section = fetchedResultsController.sections?[0] else {
            print("Нет такой секции")
            let c = tableView.dequeueReusableCell(withIdentifier: "toMe", for: indexPath) as! MessageTableViewCell
            c.sum.text = "error"
            return c
        }
        
        //let newIndexPath = IndexPath(row: section.numberOfObjects - indexPath.row - 1, section: indexPath.section)
        let transaction = fetchedResultsController.object(at: indexPath)
        
        if(transaction.sender!.userID == Int32(self.coreDataService.appUserID)) {
            cell = tableView.dequeueReusableCell(withIdentifier: "fromMe", for: indexPath) as! MessageTableViewCell
        } else{
            cell = tableView.dequeueReusableCell(withIdentifier: "toMe", for: indexPath) as! MessageTableViewCell
        }
        
        cell.delegate = self
        cell.transactionID = Int(transaction.transactionID)
        
        transaction.managedObjectContext?.performAndWait {
            if(transaction.isCash){
                cell.qiwiorNal.image = #imageLiteral(resourceName: "icon_money")
                
                if(transaction.proof == 1) {
                    cell.hideButtons()
                    //cell.makeIndicator(green: true)
                    cell.messView.layer.opacity = 1
                }else if (transaction.proof == -1){
                    cell.hideButtons()
                    cell.makeIndicator(green: false)
                    cell.messView.layer.opacity = 0.5
                } else{
                    if(self.coreDataService.appUserID != self.adminID) {
                        cell.hideButtons()
                    }
                    cell.indicator.backgroundColor = UIColor.yellow
                    cell.messView.layer.opacity = 0.5
                }
                
            } else{
                cell.qiwiorNal.image = #imageLiteral(resourceName: "qiwi_logo")
                cell.hideButtons()
                cell.indicator.backgroundColor = UIColor.clear
                cell.messView.layer.opacity = 1
            }
            cell.sum.text = String(transaction.money) + " руб."
            
        }
        
        if(!cell.isReversed){
            cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            cell.isReversed = true
        }
        
        return cell
        
        
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    var isCash = true
//    @IBAction func sendMoney(_ sender: Any) {
//        
//        isCash = true
//        showStepper()
//    }
    
//    @IBAction func sendToServer(_ sender: Any) {
//        
//        if (moneyField.text! != "") {
//            
//            
//            if(!isCash){
//                ServiceAPI.sendMoneyQiwi(phoneToSend: phone, summa: Double(moneyField.text!)!, transactionID: transactionQiwiID, noncomplitedHandler: errorHandler) {
//                    
//                    ServiceAPI.sendTransaction(dialogID: self.dialogID, money: Double(self.moneyField.text!)!, cash: self.isCash, text: "hey", noncompletedHandler: self.errorHandler) {
//                        
//                        DispatchQueue.main.async {
//                            try! self.fetchedResultsController.performFetch()
//                            self.tableView.reloadData()
//                        }
//                        
//                    }
//                }
//            } else {
//                
//                ServiceAPI.sendTransaction(dialogID: dialogID, money: Double(moneyField.text!)!, cash: isCash, text: "hey", noncompletedHandler: errorHandler) {
//                    
//                    DispatchQueue.main.async {
//                        try! self.fetchedResultsController.performFetch()
//                        self.tableView.reloadData()
//                    }
//                    
//                }
//            }
//        }
//        
//        tableView.contentInset = UIEdgeInsets.zero
//        tableView.scrollIndicatorInsets = tableView.contentInset
//        
//        moneyField.isHidden = true
//        stepper.isHidden = true
//        goButton.isHidden = true
//    }
//
//    }
  

    
     //MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SenderTableViewController {
            vc.groupId = groupID
            vc.delegate = self
        } else if let vc = segue.destination as? ParticipantsTableViewController{
            vc.adminID = adminID
            vc.groupID = groupID
        }
    }

}


extension ConferenceViewController: NSFetchedResultsControllerDelegate {
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
