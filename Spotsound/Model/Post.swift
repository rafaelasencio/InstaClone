//
//  Post.swift
//  Spotsound
//
//  Created by Rafa Asencio on 16/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import Foundation

class Post {
    var caption: String!
    var likes: Int!
    var imageUrl: String!
    var ownerId: String!
    var creationDate: Date!
    var postId: String!
    var user: User!
    
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
}


