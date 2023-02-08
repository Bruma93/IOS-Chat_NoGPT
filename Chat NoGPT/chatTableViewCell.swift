//
//  chatTableViewCell.swift
//  Chat NoGPT
//
//  Created by estech on 8/2/23.
//

import UIKit

class chatTableViewCell: UITableViewCell {


    @IBOutlet weak var mensajeLabel: UILabel!
    
    @IBOutlet weak var svMensaje: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
