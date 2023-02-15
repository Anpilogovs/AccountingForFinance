//
//  ViewController.swift
//  AccountingForFinance
//
//  Created by Сергей Анпилогов on 14.02.2023.
//

import UIKit

class ViewController: UIViewController {
    
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
    var displayValue = ""

    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    @IBAction func numberPressed(_ sender: UIButton) {
        let number = sender.currentTitle!
        
        if stillTyping {
            displayLabel.text!.count < 15
            displayLabel.text = displayLabel.text! + number
        } else {
            displayLabel.text = number
            stillTyping = true
        }
    }
    
    @IBAction func resetButton(_ sender: UIButton) {
        displayLabel.text = "0"
        stillTyping = false
    }
    
    @IBAction func categoryPressed(_ sender: UIButton) {
        categoryName = sender.currentTitle ?? "0"
        displayValue = displayLabel.text!
        displayLabel.text = "0"
        stillTyping = false
       
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        return cell
    }
    
    
}


