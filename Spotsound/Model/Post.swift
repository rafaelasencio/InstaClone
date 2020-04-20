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
}


