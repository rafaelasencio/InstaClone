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
        
        // add followed user to the current user-following structure
        USER_FOLLOWING_REF.child(currentUserUid).updateChildValues([uid : 1])
        
        // add current user to the user-followed structure
        USER_FOLLOWER_REF.child(uid).updateChildValues([currentUserUid : 1])
        
        // upload follow notification to server
        self.uploadFollowNotificationToServer()
        
        //add followed users posts to current user feed
        USER_POST_REF.child(self.uid).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            // update current user feed
            USER_FEED_REF.child(currentUserUid).updateChildValues([postId : 1])
        }
    }
    
    func unfollow(){
        
        guard let currentUserUid = Auth.auth().currentUser?.uid else {return}
        guard let uid = self.uid else {return}
        self.isFollowed = false
        
        // remove user from current user-following structure
        USER_FOLLOWING_REF.child(currentUserUid).child(uid).removeValue()
        // remove current user from user-follower structure
        USER_FOLLOWER_REF.child(uid).child(currentUserUid).removeValue()
        // remove unfollowed user posts from current user
        USER_POST_REF.child(uid).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            USER_FEED_REF.child(currentUserUid).child(postId).removeValue()
        }
    }
    
    func checkIfUserIsFollowed(completion: @escaping(Bool) ->() ){
        guard let currentUserUid = Auth.auth().currentUser?.uid else {return}
        
        USER_FOLLOWING_REF.child(currentUserUid).observeSingleEvent(of: .value) { (snapshot) in
            // check if current user is following some user
            if snapshot.hasChild(self.uid) {
                
                self.isFollowed = true
                completion(true)
            } else {
                self.isFollowed = false
                completion(false)
            }
        }
    }
    
    func uploadFollowNotificationToServer(){

        guard let currentUserUid = Auth.auth().currentUser?.uid else {return}
        let creationDate = Int(NSDate().timeIntervalSince1970)

        let values = [
        "check": 0,
        "creationDate":creationDate,
        "uid": currentUserUid,
        "type": FOLLOW_INT_VALUE] as [ String : Any]
        
        NOTIFICATIONS_REF.child(self.uid).childByAutoId().updateChildValues(values)
    }
}
