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

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        messeges = messeges.reversed()
        tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi));
        
        fetchedResultsController = coreDataService.getFRCForTransactions()
        
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        } catch{
            print(error.localizedDescription)
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messeges.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.section % 2 == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "toMe", for: indexPath) as! MessageTableViewCell
            
            if(!cell.isReversed){
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                cell.isReversed = true
            }
        
            cell.qiwiorNal.image = #imageLiteral(resourceName: "qiwi_logo")
            cell.sum.text = messeges[indexPath.row] + " руб."
        
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "fromMe", for: indexPath) as! MessageTableViewCell
            
            if(!cell.isReversed){
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                cell.isReversed = true
            }
            
            cell.qiwiorNal.image = #imageLiteral(resourceName: "qiwi_logo")
            cell.sum.text = messeges[indexPath.row] + " руб."
            
            return cell
        }
        
    }
    
    
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
