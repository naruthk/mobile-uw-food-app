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

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        if (emailTextField.text?.isEmpty)! {
            Drop.down("Email cannot be blank.", state: .error)
            return
        } else if (passwordTextField.text?.isEmpty)! {
            Drop.down("Password cannot be empty.", state: .error)
            return
        }
        
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) {
            (user, error) in
            
            if error != nil {
                print(error)
                Drop.down("Unable to register. Please try again.", state: .error)
            } else {
                
                if let accountViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Account") as? AccountViewController {
                    if let navigator = self.navigationController {
                        navigator.pushViewController(accountViewController, animated: true)
                    }
                }
                
                self.emailTextField.clearsOnBeginEditing = true
                self.passwordTextField.clearsOnBeginEditing = true
                Drop.down("Thanks for registering.", state: .success)
            }
        }
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
