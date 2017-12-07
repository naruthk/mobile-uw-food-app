//
//  FavoritesTableViewCell.swift
//  UW Food App
//
//  Created by Naruth Kongurai on 12/6/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var category: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
