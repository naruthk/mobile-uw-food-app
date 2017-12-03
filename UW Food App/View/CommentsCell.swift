//
//  CommentsCell.swift
//  UW Food App
//
//  Created by Naruth Kongurai on 12/3/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import UIKit
import Cosmos

class CommentsCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var stars: CosmosView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
