//
//  LoggedUserViewController.swift
//  iOS Firebase Test
//
//  Created by Caroline Siqueira on 06/02/17.
//  Copyright © 2017 Delivery Much. All rights reserved.
//

import UIKit
import Firebase

class LoggedUserViewController: UIViewController {

    
    @IBOutlet weak var loggedLabel: UILabel!
    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var userCover: UIImageView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.loggedLabel.text = "Welcome!"
        
        self.checkIfUserIsLoggedIn()
        
        userPicture.layer.cornerRadius = userPicture.frame.size.width / 2
        userPicture.layer.borderColor = UIColor.white.cgColor
        userPicture.layer.borderWidth = 3
        
    }
    
    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            print("Something went wrong")
            let viewController = ViewController()
            present(viewController, animated: true, completion: nil)
        } else {
            let uid = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.loggedLabel.text = "You're logged, \(dictionary["firstName"] as! String)!"
//                    print("\(dictionary["profileImageUrl"])")
                    if let profilePicture = (dictionary["profileImageUrl"] as? String), !profilePicture.isEmpty{
                        let urlProfile = URL(string: profilePicture)
                        
                        self.getDataFromUrl(url: urlProfile!) { (data, response, error)  in
                            guard let data = data, error == nil else { return }
                            DispatchQueue.main.async() { () -> Void in
                                self.userPicture.image = UIImage(data: data)
                            }
                        }
                    }
                    
                    if let coverPhoto = dictionary["coverPhotoUrl"] as? String, !coverPhoto.isEmpty {
                        let urlCover = URL(string: coverPhoto)
                        
                        self.getDataFromUrl(url: urlCover!) { (data, response, error)  in
                            guard let data = data, error == nil else { return }
                            DispatchQueue.main.async() { () -> Void in
                                self.userCover.image = UIImage(data: data)
                            }
                        }
                    }
                    
                }
                
            }, withCancel: nil)
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    @IBAction func handleLogout(_ sender: Any) {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch {
            print("Erro no logout")
        }
        
        self.performSegue(withIdentifier: "logout", sender: self)
        
    }
    


}
