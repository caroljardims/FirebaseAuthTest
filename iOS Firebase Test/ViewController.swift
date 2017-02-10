//
//  ViewController.swift
//  iOS Firebase Test
//
//  Created by Caroline Siqueira on 06/02/17.
//  Copyright © 2017 Delivery Much. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var register: UIButton!
    @IBOutlet weak var switchBtn: UIButton!
    
    var reg = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // facebook login button
        let loginButton = FBSDKLoginButton()
        loginButton.frame = CGRect(x: 35, y: 70, width: view.frame.width - 70 , height: 42)
        view.addSubview(loginButton)
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile"]
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logged out")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields" : "id, first_name, last_name, email"]).start(completionHandler: { (connection, result, err) in
            if err != nil {
                print(err as Any)
                return
            }
            
            // print(result as Any)
            let userInfos = result as! [String : Any]
            
            guard let id = userInfos["id"], let email = userInfos["email"], let firstName = userInfos["first_name"], let lastName = userInfos["last_name"] else { return }
            let values = ["firstName" : firstName, "lastName" : lastName, "email" : email, "profileImageUrl" : "http://graph.facebook.com/\(id)/picture?type=large"]
            let accessToken = FBSDKAccessToken.current()
            guard let accessTokenString = accessToken?.tokenString else { return }
            
            let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
            FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
                if error != nil {
                    print(error as Any)
                    return
                }
                
                print("user was successfully saved on firebase")
                self.saveOnFirebirdDB(values: values)
                
            })

            
            
        })
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
            
            let values = ["firstName" : name, "lastName" : lastName, "email" : email]
            self.saveOnFirebirdDB(values: values)
        })
    }
    
    func saveOnFirebirdDB(values:[String:Any]){
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        
        let ref = FIRDatabase.database().reference(fromURL: "https://ios-dm-test.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)
        usersReference.onDisconnectUpdateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err as Any)
                print("DEU ERRO AQUI D:")
                return
            }
            print("Saved user successfully")
            self.performSegue(withIdentifier: "logged", sender: self)
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

