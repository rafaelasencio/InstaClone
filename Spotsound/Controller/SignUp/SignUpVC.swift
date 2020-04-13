//
//  SignUpVC.swift
//  Spotsound
//
//  Created by Rafa Asencio on 12/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit
import Firebase

class SignUpVC: UIViewController {
    
    
    var imageSelected = false
    
    let addPhotoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(pickUserPhoto), for: .touchUpInside)
        return btn
    }()
    
    let emailTextfield: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let passwordTextfield: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let fullNameTextfield: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Full Name"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()
    
    let userNameTextfield: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()
    
    let signUpButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Sign Up", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        btn.layer.cornerRadius = 5
        btn.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return btn
    }()
    
    let alreadyAccountButton: UIButton = {
        let btn = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
        btn.setAttributedTitle(attributedTitle, for: .normal)
        btn.addTarget(self, action: #selector(goToLogin), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(addPhotoButton)
        addPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 150)
        addPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        configureViewComponents()
    }
    
    func configureViewComponents(){
        let stackView = UIStackView(arrangedSubviews: [fullNameTextfield, userNameTextfield, emailTextfield, passwordTextfield, signUpButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        stackView.anchor(top: addPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 240)
        view.addSubview(alreadyAccountButton)
        alreadyAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 40, paddingRight: 0, width: 0, height: 40)
    }
    
    @objc func goToLogin(){
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func handleSignUp(){
        guard let email = emailTextfield.text else {return}
        guard let password = passwordTextfield.text else {return}
        guard let username = userNameTextfield.text else {return}
        guard let fullname = fullNameTextfield.text else {return}
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            
            // handle error
            if let error = error {
                print("DEBUG: Failed to create user with error: ", error.localizedDescription)
                return
            }
            
            guard let profileImg = self.addPhotoButton.imageView?.image else { return }
            //upload photo
            guard let uploadData = profileImg.jpegData(compressionQuality: 0.3) else { return }
            
            let filename = NSUUID().uuidString
            
            // UPDATE: - In order to get download URL must add filename to storage ref like this
            let storageRef = Storage.storage().reference().child("profile_images").child(filename)
            
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                // handle error
                if let error = error {
                    print("Failed to upload image to Firebase Storage with error", error.localizedDescription)
                    return
                }
                
                // UPDATE: - Firebase 5 must now retrieve download url
                storageRef.downloadURL(completion: { (downloadURL, error) in
                    guard let profileImageUrl = downloadURL?.absoluteString else {
                        print("DEBUG: Profile image url is nil")
                        return
                    }

                    // user id
                    guard let uid = authResult?.user.uid else { return }
//                    guard let fcmToken = Messaging.messaging().fcmToken else { return }

                    let dictionaryValues = ["name": fullname,
                                            "username": username,
                                            "profileImageUrl": profileImageUrl]

                    let values = [uid: dictionaryValues]

                    // save user info to database
                    Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (error, ref) in

                        
//                        guard let mainTabVC = UIApplication.shared.keyWindow?.rootViewController as? MainTabVC else { return }
//
//                        // configure view controllers in maintabvc
//                        mainTabVC.configureViewControllers()
//                        mainTabVC.isInitialLoad = true

                        // dismiss login controller
                        self.dismiss(animated: true, completion: nil)
                    })
                })
            })
        }
        
    }
    @objc func formValidation(){
        guard emailTextfield.hasText, passwordTextfield.hasText, fullNameTextfield.hasText, userNameTextfield.hasText, imageSelected else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        signUpButton.isEnabled = true
        signUpButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
    }
    
    
    
}


extension SignUpVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func pickUserPhoto(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        self.present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let profileImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            imageSelected = false
            return
        }
        
        imageSelected = true
        addPhotoButton.layer.cornerRadius = addPhotoButton.frame.height / 2
        addPhotoButton.layer.masksToBounds = true
        addPhotoButton.layer.borderColor = UIColor.black.cgColor
        addPhotoButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        self.dismiss(animated: true, completion: nil)
    }
}
