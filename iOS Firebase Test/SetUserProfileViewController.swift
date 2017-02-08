//
//  SetUserProfileViewController.swift
//  iOS Firebase Test
//
//  Created by Caroline Siqueira on 07/02/17.
//  Copyright © 2017 Delivery Much. All rights reserved.
//

import UIKit
import Firebase

class SetUserProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    
    @IBOutlet weak var userPicture: UIImageView!
    @IBOutlet weak var coverPicture: UIImageView!
    @IBOutlet weak var coverCamera: UIImageView!
    
    
    let imagePicker = UIImagePickerController()
    var profile = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        userPicture.layer.cornerRadius = userPicture.frame.size.width / 2
        userPicture.layer.borderColor = UIColor.white.cgColor
        userPicture.layer.borderWidth = 3
        imagePicker.delegate = self

    }
    
    @IBAction func choseCoverPhoto(_ sender: Any) {
        profile = false
        
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
        
    }

    func uploadUserSettings() {
        
        if let firstName = firstName.text, !firstName.isEmpty {
            let values = ["firstName": firstName]
            self.registerUserIntoDatabaseWithUID(uid: (FIRAuth.auth()?.currentUser?.uid)!, values: values as [String : AnyObject])
        }
        
        if let lastName = lastName.text, !lastName.isEmpty {
            let values = ["lastName": lastName]
            self.registerUserIntoDatabaseWithUID(uid: (FIRAuth.auth()?.currentUser?.uid)!, values: values as [String : AnyObject])
        }
    }
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference(fromURL: "https://ios-dm-test.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err as Any)
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @IBAction func save(_ sender: Any) {
        uploadUserSettings()
        let alert = UIAlertController(title: "Saved", message: "Your settings are updated", preferredStyle: .actionSheet)
        self.present(alert, animated: true)
    }
    
    @IBAction func showPassword(_ sender: Any) {
        
        if password.isSecureTextEntry {
            password.isSecureTextEntry = false
        } else {
            password.isSecureTextEntry = true
        }
    }
    
    
    @IBAction func choseImageForProfilePicture(_ sender: Any) {
        
        profile = true
        
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.updatePhotoData(image: pickedImage)
        }
//        dismiss(animated: true, completion: nil)
    }
    
    func updatePhotoData(image: UIImage) {
        
        if profile {
            userPicture.contentMode = .scaleAspectFill
            userPicture.image = image
            let imageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).png")
            let uploadData = UIImagePNGRepresentation(userPicture.image!)
            
            storageRef.put(uploadData!, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error as Any)
                    return
                }
                
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                    let values = ["profileImageUrl": profileImageUrl]
                    self.registerUserIntoDatabaseWithUID(uid: (FIRAuth.auth()?.currentUser?.uid)!, values: values as [String : AnyObject])
                }
            })
        } else {
            coverPicture.contentMode = .scaleAspectFill
            coverPicture.image = image
            let imageName = NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("cover_photos").child("\(imageName).png")
            let uploadData = UIImagePNGRepresentation(coverPicture.image!)
            
            storageRef.put(uploadData!, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error as Any)
                    return
                }
                
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                    let values = ["coverPhotoUrl": profileImageUrl]
                    self.registerUserIntoDatabaseWithUID(uid: (FIRAuth.auth()?.currentUser?.uid)!, values: values as [String : AnyObject])
                }
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
