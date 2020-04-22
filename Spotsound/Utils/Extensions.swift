//
//  Extensions.swift
//  Spotsound
//
//  Created by Rafa Asencio on 12/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit
import Firebase

extension UIButton {
    
    func configure(didFollow: Bool){
        if didFollow {
            // handle follow user
            self.setTitle("Following", for: .normal)
            self.setTitleColor(.black, for: .normal)
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.layer.borderWidth = 0.5
            self.backgroundColor = .white
        } else {
            //handle unfollow user
            self.setTitle("Follow", for: .normal)
            self.setTitleColor(.white, for: .normal)
            self.layer.borderWidth = 0
            self.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        }
        
        
        
    }
}

extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat){
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}


extension UIImageView {
    
}

extension Database {
    
    
    static func fetchUser(with uid: String, completion:@escaping(User)->()) {
        
        USER_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let dict = snapshot.value as? Dictionary<String, AnyObject> else {return}
            let user = User(uid: uid, dict: dict)
            completion(user)
        }
    }
    
    static func fetchPost(with postId: String, completion:@escaping(Post)->() ){
        
        POSTS_REF.child(postId).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return}
            guard let ownerUid = dictionary["ownerUid"] as? String else {return}
            
            Database.fetchUser(with: ownerUid) { (user) in
                let post = Post(user: user, postId: postId, dicctionary: dictionary)
                completion(post)
            }
        }
    }
}
