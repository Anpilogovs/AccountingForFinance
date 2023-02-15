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
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spendingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! CustomTableViewCell
        
        let spending = spendingArray[indexPath.row]
        cell.recordCategory.text  = spending.category
        cell.recordCost.text = "\(spending.cost)"
        
        switch spending.category {
        case "Food": cell.recordImage.image = #imageLiteral(resourceName: "delivery-bike")
        case "Cloth": cell.recordImage.image = #imageLiteral(resourceName: "apparel")
        case "Connect": cell.recordImage.image = #imageLiteral(resourceName: "internet")
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


