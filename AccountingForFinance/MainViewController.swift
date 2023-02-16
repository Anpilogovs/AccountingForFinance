//
//  ViewController.swift
//  AccountingForFinance
//
//  Created by Сергей Анпилогов on 14.02.2023.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    let realm = try! Realm()
    var spendingArray: Results<Spending>!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var spendByCheck: UILabel!
    @IBOutlet weak var limitLabel: UILabel!
    @IBOutlet weak var howManyCanSpend: UILabel!
    
    var stillTyping = false
    
    @IBOutlet  var numberFromKeyBoard: [UIButton]! {
        didSet {
            for button in numberFromKeyBoard {
                button.layer.cornerRadius = 10
            }
        }
    }
    
    var categoryName = ""
    var displayValue: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spendingArray = realm.objects(Spending.self)
        
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
        let number = sender.currentTitle!
        
        if number == "0" && displayLabel.text == "0" {
            stillTyping = false
        } else {
            if stillTyping {
                displayLabel.text!.count < 15
                displayLabel.text = displayLabel.text! + number
            } else {
                displayLabel.text = number
                stillTyping = true
            }
        }
    }
    
    @IBAction func resetButton(_ sender: UIButton) {
        displayLabel.text = "0"
        stillTyping = false
    }
    
    @IBAction func categoryPressed(_ sender: UIButton) {
        categoryName = sender.currentTitle!
        displayValue = Int(displayLabel.text!)!
        displayLabel.text = "0"
        stillTyping = false
        
        let value = Spending(value: ["\(categoryName)", displayValue])
        try! realm.write({
            realm.add(value)
        })
        tableView.reloadData()
    }
    
    @IBAction func limitPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Install Limite", message: "Input summ and count days", preferredStyle: .alert)
        let alertInstall = UIAlertAction(title: "Install", style: .default) { action in
            
            let tfSumm = alertController.textFields?[0].text
            self.limitLabel.text = tfSumm
            
            let tfDay = alertController.textFields?[1].text
            
            guard tfDay != "" else { return }
            
            if let day = tfDay {
                let dateNow = Date()
                let lastDay: Date = dateNow.addingTimeInterval(60*60*24*Double(day)!)
                
                let limit = self.realm.objects(Limit.self)
                
                if limit.isEmpty == true {
                    //Записываем
                    let value = Limit(value: [self.limitLabel.text, dateNow, lastDay])
                    try! self.realm.write({
                        self.realm.add(value)
                    })
                } else {
                    //Перезаписываем данные
                    try! self.realm.write({
                        limit[0].limitSum = self.self.limitLabel.text!
                        limit[0].limitDate = dateNow as Date
                        limit[0].limitLastDay = lastDay as Date
                    })
                }
            }
        }
        alertController.addTextField { (money) in
            money.placeholder = "Inpum summ"
            money.keyboardType = .asciiCapableNumberPad
        }
        
        alertController.addTextField { (day) in
            day.placeholder = "Input days"
            day.keyboardType = .asciiCapableNumberPad
        }
        
        let alertCancel = UIAlertAction(title: "Cancel", style: .default) { _ in }
        
        alertController.addAction(alertInstall)
        alertController.addAction(alertCancel)
        
        present(alertController, animated: true)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spendingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! CustomTableViewCell
        
        let spending = spendingArray.reversed()[indexPath.row]
        cell.recordCategory.text  = spending.category
        cell.recordCost.text = "\(spending.cost)"
        
        switch spending.category {
        case "Food": cell.recordImage.image = #imageLiteral(resourceName: "delivery-bike")
        case "Cloth": cell.recordImage.image = #imageLiteral(resourceName: "apparel")
        case "Connection": cell.recordImage.image = #imageLiteral(resourceName: "internet")
        case "Leisure": cell.recordImage.image = #imageLiteral(resourceName: "reading")
        case "Beautiful": cell.recordImage.image = #imageLiteral(resourceName: "after-shave")
        case "Car": cell.recordImage.image = #imageLiteral(resourceName: "car")
        default: cell.recordImage.image = #imageLiteral(resourceName: "no-task")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editingRow = spendingArray[indexPath.row]
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") {  (_, _) in
            try! self.realm.write({
                self.realm.delete(editingRow)
                tableView.reloadData()
            })
        }
        return [deleteAction]
    }
}


