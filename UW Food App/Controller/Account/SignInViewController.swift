//
//  WelcomeScreenForAccountViewController.swift
//  UW Food App
//
//  Created by Naruth Kongurai on 12/4/17.
//  Copyright © 2017 iSchool. All rights reserved.
//

import UIKit
import Firebase
import SwiftyDrop
import ChameleonFramework

class SignInViewController: UIViewController {
    
    var favorites = SharedInstance.sharedInstance
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        self.favorites.favoritesItemDictionary.removeAll()
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "goToAccount", sender: self)
        } else {
            do {
                try Auth.auth().signOut()
                return
            } catch {
                print(error)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dismiss(animated: false) {}
        
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "goToAccount", sender: self)
        } else {
            do {
                try Auth.auth().signOut()
                return
            } catch {
                print(error)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func signInButtonPressed(_ sender: Any) {
        
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
    
}
