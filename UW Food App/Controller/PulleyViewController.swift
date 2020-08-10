//
//  PulleyViewController.swift
//  UW Food App
//
//  Created by Thipok Cholsaipant on 8/10/20.
//  Copyright © 2020 iSchool. All rights reserved.
//

import Foundation
import Pulley

class MainPulleyViewController: UIViewController {
    
    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var accountView: UIView!
    @IBOutlet weak var accountViewBlur: UIVisualEffectView!
    @IBOutlet weak var pulleyView: MainPulleyViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAccountView()
        initAccountButton()
    }
    
    func initAccountButton() {
        view.bringSubviewToFront(accountButton)
        accountButton.setImage(UIImage(fluent: .person28Filled), for: .normal)
        accountButton.layer.shadowOpacity = 0.25;
        accountButton.layer.shadowRadius = 12;
    }
    
    func initAccountView() {
        accountViewBlur.effect = nil
    }
    
    @IBAction func openAccountView(_ sender: Any) {
//        pulleyView.pulleyViewController!.setDrawerPosition(position: .closed, animated: true)
        
//        let accountVC = storyboard!.instantiateViewController(withIdentifier: "Account")
//        
//        accountView.alpha = 0.0
//        view.bringSubviewToFront(accountViewBlur)
//        view.bringSubviewToFront(accountView)
//        UIView.animate(withDuration: 0.25) {
//            self.accountViewBlur.effect = UIBlurEffect(style: UIBlurEffect.Style.light)
//            self.accountView.alpha = 1.0
//        }
    }
}
