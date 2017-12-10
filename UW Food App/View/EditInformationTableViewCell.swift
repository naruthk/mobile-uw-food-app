//
//  TextFieldTableViewCell.swift
//  UW Food App
//
//  Created by Thipok Cholsaipant on 12/10/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import UIKit

class EditInformationTableViewCell: UITableViewCell, UITextFieldDelegate {

    var information:Information! {
        didSet {
            self.label.text = information.label
            self.textField.placeholder = information.information
        }
    }
    
    var onEditingInformationDidEnd:(() -> ())!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func editingInformationDidEnd(_ sender: UITextField) {
        if onEditingInformationDidEnd != nil {
            onEditingInformationDidEnd()
        }
    }
    
    func commitInformation() {
        // If information exists and textfield
        if information != nil &&
            textField.text != ""{
            information.information = textField.text
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    

}

