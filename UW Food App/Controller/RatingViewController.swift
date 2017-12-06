//
//  RatingViewController.swift
//  UW Food App
//
//  Created by Naruth Kongurai on 12/3/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import UIKit
import Cosmos

class RatingViewController: UIViewController {

    @IBOutlet weak var ratingPanel: CosmosView!
    @IBOutlet weak var commentTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTextField.delegate = self
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func endEditing() {
        view.endEditing(true)
    }
    
    func setupRatingFunctionalities() {
        ratingPanel.settings.updateOnTouch = true
        ratingPanel.settings.starMargin = 1
        ratingPanel.settings.starSize = 45
        ratingPanel.settings.fillMode = .precise
        let color : UIColor = UIColor.flatRed()
        ratingPanel.settings.filledColor = color
        ratingPanel.settings.emptyBorderColor = color
        ratingPanel.settings.filledBorderColor = color
    }
    
    func returnData() -> [String] {
        guard let comment = commentTextField.text else { return [""]}
        var array : [String] = []
        array.append(comment)
        array.append(String(ratingPanel.rating))
        return array
    }
    
}

extension RatingViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing()
        return true
    }
}
