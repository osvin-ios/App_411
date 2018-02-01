//
//  TableViewPlacesCell.swift
//  App411
//
//  Created by osvinuser on 9/19/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class TableViewPlacesCell: UITableViewCell {

    @IBOutlet var imageView_icon: DesignableImageView!
    
    @IBOutlet var label_Title: UILabel!
    
    @IBOutlet var label_SubTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
