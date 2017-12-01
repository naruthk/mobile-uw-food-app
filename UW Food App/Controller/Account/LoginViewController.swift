
//  LoginViewController.swift
//  UW Food App
//
//  Created by Naruth Kongurai on 11/29/17.
//  Copyright © 2017 iSchool. All rights reserved.


import UIKit
import Firebase
import SwiftyDrop

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginButtonPressed(_ sender: Any) {
        
        if (emailTextField.text?.isEmpty)! {
            Drop.down("Please specify a valid email address.", state: .error)
            return
        } else if (passwordTextField.text?.isEmpty)! {
            Drop.down("Please specify a proper password.", state: .error)
            return
        }
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
            
            if error != nil {
                print(error ?? "")
                Drop.down("Unable to sign in. Please try again.", state: .error)
            } else {
                
                self.performSegue(withIdentifier: "goToAccount", sender: self)
                
                self.emailTextField.clearsOnBeginEditing = true
                self.passwordTextField.clearsOnBeginEditing = true
            }

        })
    
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

