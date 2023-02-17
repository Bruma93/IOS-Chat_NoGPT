//
//  chatTableViewCell.swift
//  Chat NoGPT
//
//  Created by estech on 8/2/23.
//

import UIKit

class chatTableViewCell: UITableViewCell {


    @IBOutlet weak var mensajeLabel: UILabel!
    @IBOutlet weak var horaLabel: UILabel!
    
    @IBOutlet weak var vista: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        vista.layer.cornerRadius=20    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
