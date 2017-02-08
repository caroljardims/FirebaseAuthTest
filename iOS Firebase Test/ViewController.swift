//
//  ViewController.swift
//  iOS Firebase Test
//
//  Created by Caroline Siqueira on 06/02/17.
//  Copyright © 2017 Delivery Much. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var register: UIButton!
    @IBOutlet weak var switchBtn: UIButton!
    
    var reg = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if FIRAuth.auth()?.currentUser?.uid != nil {
            self.performSegue(withIdentifier: "logged", sender: self)
        }
    }

    // registrar || login
    @IBAction func registerButton(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text, let lastName = lastNameTextField.text else {
            print("Form not valid")
            return
        }
        
        if reg {
            handleRegister(name: name, lastName: lastName, email: email, password: password)
        } else {
            handleLogin(email: email, password: password)
        }
    }
    
    func handleRegister(name:String, lastName:String, email:String, password:String) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            if error != nil {
                print(error as Any)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            let values = ["firstName" : name, "lastName" : lastName, "email" : email]
            let ref = FIRDatabase.database().reference(fromURL: "https://ios-dm-test.firebaseio.com/")
            let usersReference = ref.child("users").child(uid)
            usersReference.onDisconnectUpdateChildValues(values, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print(err as Any)
                    return
                }
                print("Saved user successfully")
                self.performSegue(withIdentifier: "logged", sender: self)
            })
        })
    }
    
    func handleLogin(email:String, password:String) {
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print(error as Any)
                return
            }
            
            self.performSegue(withIdentifier: "logged", sender: self)
        })
    }
    
    // login
    @IBAction func switchButton(_ sender: Any) {
        if reg {
            reg = false
            nameTextField.isHidden = true
            lastNameTextField.isHidden = true
            register.setTitle("Login", for: .normal)
            switchBtn.setTitle("Doesn't have an Account?", for: .normal)
        } else {
            reg = true
            nameTextField.isHidden = false
            lastNameTextField.isHidden = false
            register.setTitle("Register", for: .normal)
            switchBtn.setTitle("Already have an Account?", for: .normal)
        }
    }

    

}

