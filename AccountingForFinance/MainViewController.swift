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
    @IBOutlet weak var allSpending: UILabel!
    
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
        leftLabels()
        spendingAllTime()
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
        leftLabels()
        spendingAllTime()
        tableView.reloadData()
    }
    
    @IBAction func limitPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Install Limite", message: "Input summ and count days", preferredStyle: .alert)
        let alertInstall = UIAlertAction(title: "Install", style: .default) { action in
            
            let tfSumm = alertController.textFields?[0].text
            let tfDay = alertController.textFields?[1].text
            
            guard tfDay != "" && tfSumm != "" else { return }
            
            self.limitLabel.text = tfSumm
            
            if let day = tfDay {
                let dateNow = Date()
                let lastDay: Date = dateNow.addingTimeInterval(60*60*24*Double(day)!)
                
                let limit = self.realm.objects(Limit.self)
                
                if limit.isEmpty == true {
                    //Записываем
                    let value = Limit(value: [self.limitLabel.text as Any, dateNow, lastDay])
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
            self.leftLabels()
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
    
    func leftLabels()  {
        
        let limit = self.realm.objects(Limit.self)
        
        guard limit.isEmpty == false else { return }
        
        limitLabel.text = limit[0].limitSum
        
        let calendar = Calendar.current
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        let firstDay = limit[0].limitDate
        let lastDay = limit[0].limitLastDay
        
        let firstComponents = calendar.dateComponents([.year, .month, .day], from: firstDay)
        let lastComponents = calendar.dateComponents([.year, .month, .day], from: lastDay)
        //        2020/04/20
        let startDate = formatter.date(from: "\(firstComponents.year!)/\(firstComponents.month!)/\(firstComponents.day!) 00:00") as Any
        //        2020/04/20
        let endDate = formatter.date(from: "\(lastComponents.year!)/\(lastComponents.month!)/\(lastComponents.day!) 23:59") as Any
        //делаем выборку и все значение cost -(cкладываются между собой)
        let filtredLimit: Int = realm.objects(Spending.self).filter("self.date >= %@ && self.date <= %@", startDate, endDate).sum(ofProperty: "cost")
        
        spendByCheck.text = "\(filtredLimit)"
        
        let a = Int(limitLabel.text!)!
        let b = Int(spendByCheck.text!)!
        let c = a - b
        
        howManyCanSpend.text = "\(c)"
        
        
        //расходы за месяц:
        let dateNow = Date()
        
        let dateComponentsNow = calendar.dateComponents([.year, .month, .day], from: dateNow)
        let lastDayMonth: Int
        
        if Int(dateComponentsNow.year!) % 4 == 0 && dateComponentsNow.month == 2  {
            lastDayMonth = 29
        } else {
            
            switch dateComponentsNow.month {
            case 1: lastDayMonth = 31
            case 2: lastDayMonth = 28
            case 3: lastDayMonth = 31
            case 4: lastDayMonth = 30
            case 5: lastDayMonth = 31
            case 6: lastDayMonth = 30
            case 7: lastDayMonth = 31
            case 8: lastDayMonth = 31
            case 9: lastDayMonth = 30
            case 10: lastDayMonth = 31
            case 11: lastDayMonth = 30
            case 12: lastDayMonth = 31
                
            default: return
            }
        }
        //        2020/04/20
        let startDateMonth = formatter.date(from: "\(dateComponentsNow.year!)/\(dateComponentsNow.month!)/1 00:00") as Any
        //        2020/04/20
        let endDateMonth = formatter.date(from: "\(dateComponentsNow.year!)/\(dateComponentsNow.month!)/\(lastDayMonth) 23:59") as Any
      
        let filtredMonth: Int = realm.objects(Spending.self).filter("self.date >= %@ && self.date <= %@", startDateMonth, endDateMonth).sum(ofProperty: "cost")
        
        print(filtredMonth)

    }
    
    func spendingAllTime() {
        let allSpend: Int = realm.objects(Spending.self).sum(ofProperty: "cost")
        allSpending.text = "\(allSpend)"
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spendingArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! CustomTableViewCell
        
        let spending = spendingArray.sorted(byKeyPath: "date", ascending: false)[indexPath.row]
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let editingRow = spendingArray.sorted(byKeyPath: "date", ascending: false)[indexPath.row]
        
        if editingStyle == .delete {
            try! self.realm.write({
                self.realm.delete(editingRow)
                self.leftLabels()
                self.spendingAllTime()
                tableView.reloadData()
            })
        }
    }
}


