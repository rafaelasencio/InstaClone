//
//  Notification.swift
//  Spotsound
//
//  Created by Rafa Asencio on 20/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import Foundation

class Notification {
    
    enum NotificationType: Int, Printable {
        case Like
        case Comment
        case Follow
        case CommentMention
        case PostMention
        
        var description: String {
            switch self {
                case .Like: return " liked yout post"
                case .Comment: return " commented your post"
                case .Follow: return " started following you"
                case .CommentMention: return " mentioned you in a comment"
                case .PostMention: return " mentioned you in a post"
            }
        }
        
        init(index: Int) {
            switch index {
                case 0: self = .Like
                case 1: self = .Comment
                case 2: self = .Follow
                case 3: self = .CommentMention
                case 4: self = .PostMention
                default: self = .Like
            }
        }
    }
    
    var creationDate: Date!
    var uid: String!
    var postId: String?
    var post: Post?
    var user: User!
    var type: Int?
    var notificationType: NotificationType!
    var didCheck = false
    
    // init for notification with optional post in case of liking post
    init(user: User, post: Post? = nil, dictionary: Dictionary<String, AnyObject>) {
        
        self.user = user
        
        if let post = post {
            self.post = post
        }
        
        if let creationDate = dictionary["creationDate"] as? Double{
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
        
        if let type = dictionary["type"] as? Int {
            self.notificationType = NotificationType.init(index: type)
        }
        
        if let uid = dictionary["uid"] as? String {
            self.uid = uid
        }
        
        if let postId = dictionary["postId"] as? String {
            self.postId = postId
        }
        
        if let check = dictionary["check"] as? Int {

            didCheck = check == 0 ? false : true
        }
        
    }
}
