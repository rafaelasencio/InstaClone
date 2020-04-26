//
//  Post.swift
//  Spotsound
//
//  Created by Rafa Asencio on 16/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import Foundation
import Firebase

class Post {
    var caption: String!
    var likes: Int!
    var imageUrl: String!
    var ownerId: String!
    var creationDate: Date!
    var postId: String!
    var user: User!
    var didLike = false

    init(user: User, postId: String, dicctionary: Dictionary<String, AnyObject>) {
        self.user = user
        self.postId = postId
        
        if let caption = dicctionary["caption"] as? String {
            self.caption = caption
        }
        
        if let likes = dicctionary["likes"] as? Int {
            self.likes = likes
        }
        
        if let imageUrl = dicctionary["imageUrl"] as? String {
            self.imageUrl = imageUrl
        }
        
        if let ownerId = dicctionary["ownerUid"] as? String {
            self.ownerId = ownerId
        }
        
        if let creationDate = dicctionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
        
    }
    
    
    // called every time we like post
    func adjustLikes(addLike: Bool, completion: @escaping(Int) ->() ){
        
        guard let currentUserUid = Auth.auth().currentUser?.uid else {return}
        guard let postId = self.postId else { return }
        
        if addLike {
            
            //update user-likes structure
            USER_LIKES_REF.child(currentUserUid).updateChildValues([postId : 1]) { (error, ref) in
                
                // send notification to server
                self.sendLikeNotificationToServer()
                
                //update post-likes structure
                POST_LIKES_REF.child(self.postId).updateChildValues([currentUserUid : 1]) { (err, ref) in

                    //set when finish updating in DB
                    self.likes = self.likes + 1
                    self.didLike = true
                    completion(self.likes)
                    POSTS_REF.child(self.postId).child("likes").setValue(self.likes)
                }
            }
            
            
        } else {
            
            //observe db for notification id to remove
            USER_LIKES_REF.child(currentUserUid).child(postId).observeSingleEvent(of: .value) { (snapshot) in
                
                //notification id to remove from server
                guard let notificationId = snapshot.value as? String else {return}
                
                NOTIFICATIONS_REF.child(self.ownerId).child(notificationId).removeValue { (err, ref) in
                    
                    // remove like from user-likes structure
                    USER_LIKES_REF.child(currentUserUid).child(postId).removeValue { (err, ref) in
                        
                        // remove like post-likes structure
                        POST_LIKES_REF.child(self.postId).child(currentUserUid).removeValue { (err, ref) in
                            
                            //set when finish updating in DB
                            guard self.likes > 0 else {return}
                            self.likes = self.likes - 1
                            self.didLike = false
                            completion(self.likes)
                            POSTS_REF.child(self.postId).child("likes").setValue(self.likes)
                        }
                    }
                }
            }
        }
    }
    
    
    func sendLikeNotificationToServer(){
        
        // properties
        guard let currentUserUid = Auth.auth().currentUser?.uid else {return}
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        
        // only send notification when user who liked it is not current user
        if currentUserUid != self.ownerId {
            
            // notification values
            let values = [
                "check": 0,
                "creationDate":creationDate,
                "uid": currentUserUid,
                "type": LIKE_INT_VALUE,
                "postId":postId] as [ String : Any ]
            
            // notification db reference
            let notificationRef = NOTIFICATIONS_REF.child(self.ownerId).childByAutoId()
            
            // upload notification values to db
            notificationRef.updateChildValues(values) { (err, ref) in
                USER_LIKES_REF.child(currentUserUid).child(self.postId).setValue(notificationRef.key)
            }
        }
    }
    
    func deletePost(){
        print("delete post")
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        
        // delete photo from storage
        Storage.storage().reference(forURL: self.imageUrl).delete(completion: nil)
        
        // remove post from user followers feed
        USER_FOLLOWER_REF.child(currentUserUid).observe(.childAdded) { (snapshot) in
            let followerUid = snapshot.key
            USER_FEED_REF.child(followerUid).child(self.postId).removeValue()
        }
        
        // remove post from current user feed
        USER_FEED_REF.child(currentUserUid).child(self.postId).removeValue()
        
        // remove from user post
        USER_POST_REF.child(currentUserUid).child(self.postId).removeValue()
        
        // remove from post likes
        POST_LIKES_REF.child(self.postId).observe(.childAdded) { (snapshot) in
            let uid = snapshot.key
            print("uid: ", uid)
            USER_LIKES_REF.child(uid).child(self.postId).observeSingleEvent(of: .value) { (snapshot) in
                guard let notificationId = snapshot.value as? String else { return }
                print("notificationId: ", notificationId)
                // remove from notifications
                NOTIFICATIONS_REF.child(self.ownerId).child(notificationId).removeValue { (err, ref) in
                    //first from post-likes, after from user-likes to still having notificationUid value
                    POST_LIKES_REF.child(self.postId).removeValue()
                    USER_LIKES_REF.child(uid).child(self.postId).removeValue()
                }
            }
        }
        
        let words = caption.components(separatedBy: .whitespacesAndNewlines)
        // loops array with words in caption
        for var word in words {
            if word.hasPrefix("#") {
                word = word.trimmingCharacters(in: .punctuationCharacters)
                word = word.trimmingCharacters(in: .symbols)
                // delete from hashtag struct with word value
                HASHTAG_POST_REF.child(word).child(postId).removeValue()
            }
        }
        
        COMMENT_REF.child(postId).removeValue()
        POSTS_REF.child(postId).removeValue()
        
    }
    
    
}


