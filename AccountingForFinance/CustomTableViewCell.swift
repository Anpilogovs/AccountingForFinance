//
//  CustomTableViewCell.swift
//  AccountingForFinance
//
//  Created by Сергей Анпилогов on 15.02.2023.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var recordImageView: UIImageView!
    @IBOutlet weak var recordCategory: UILabel!
    @IBOutlet weak var recordCost: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
