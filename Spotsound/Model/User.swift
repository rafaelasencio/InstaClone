//
//  User.swift
//  Spotsound
//
//  Created by Rafa Asencio on 13/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import Foundation
import Firebase

class User {
    var username: String!
    var name: String!
    var profileImageUrl: String!
    var uid: String!
    var isFollowed = false
    
    init(uid: String, dict: Dictionary<String, AnyObject>) {
        self.uid = uid
        
        if let username = dict["username"] as? String {
            self.username = username
        }
        if let name = dict["name"] as? String {
            self.name = name
        }
        if let profileImageUrl = dict["profileImageUrl"] as? String {
            self.profileImageUrl = profileImageUrl
        }
    }
    
    func follow(){
        
        guard let currentUserUid = Auth.auth().currentUser?.uid else {return}
        guard let uid = uid else {return}
        self.isFollowed = true
        
        USER_FOLLOWING_REF.child(currentUserUid).updateChildValues([uid : 1])
        USER_FOLLOWER_REF.child(uid).updateChildValues([currentUserUid : 1])
    }
    
    func unfollow(){
        
        guard let currentUserUid = Auth.auth().currentUser?.uid else {return}
        guard let uid = uid else {return}
        self.isFollowed = false
        
        USER_FOLLOWING_REF.child(currentUserUid).child(uid).removeValue()
        USER_FOLLOWER_REF.child(uid).child(currentUserUid).removeValue()
    }
    
    func checkIfUserIsFollowed(completion: @escaping(Bool) ->() ){
        guard let currentUserUid = Auth.auth().currentUser?.uid else {return}
        
        USER_FOLLOWING_REF.child(currentUserUid).observeSingleEvent(of: .value) { (snapshot) in
            // check if current user is following this user
            if snapshot.hasChild(self.uid) {
                
                self.isFollowed = true
                print("user is followed")
                completion(true)
            } else {
                self.isFollowed = false
                print("user not followed")
                completion(false)
            }
        }
        
        
    }
}
