//
//  RegisterViewController.swift
//  UW Food App
//
//  Created by Naruth Kongurai on 11/28/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import UIKit
import Firebase
import SwiftyDrop
import PopupDialog

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var infoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        let title = "Display Name"
        let message = "A display name is what everybody else sees when they read your reviews. Feel free to pick anything you want now. You can always change it later if you want."
        let popup = PopupDialog(title: title, message: message)
        let close = CancelButton(title: "I got it!") {}
        popup.addButton(close)
        self.present(popup, animated: true, completion: nil)
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        if (emailTextField.text?.isEmpty)! {
            Drop.down("Please specify a valid email address.", state: .error)
            return
        } else if (passwordTextField.text?.isEmpty)! {
            Drop.down("Please specify a proper password.", state: .error)
            return
        }
        
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) {
            (user, error) in
            
            if error != nil {
                print(error ?? "")
                Drop.down("Unable to register. Please try again.", state: .error)
            } else if let user = user {
                let changeRequest = user.user.createProfileChangeRequest()
                changeRequest.displayName = self.displayNameTextField.text
                changeRequest.commitChanges(completion: { error in
                    if let error = error {
                        print(error)
                    } else {
                        let title = "Registration Successful!"
                        let message = "Thanks for signing up an account with us. You can now leave reviews for any restaurants."
                        let popup = PopupDialog(title: title, message: message, tapGestureDismissal: false)
                        let close = CancelButton(title: "Close") {
                            self.emailTextField.clearsOnBeginEditing = true
                            self.passwordTextField.clearsOnBeginEditing = true
                            self.performSegue(withIdentifier: "goToAccount", sender: self)
                        }
                        popup.addButton(close)
                        self.present(popup, animated: true, completion: nil)
                    }
                })
            }
        }
    }
}
