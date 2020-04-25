//
//  UploadPostVC.swift
//  Spotsound
//
//  Created by Rafa Asencio on 12/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit
import Firebase

class UploadPostVC: UIViewController, UITextViewDelegate {

    //MARK: - Properties
    var selectedImage: UIImage?
    
    let photoImageView: UIImageView = {
       let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    let captionTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = UIColor.groupTableViewBackground
        tv.font = UIFont.systemFont(ofSize: 12)
        return tv
    }()
    
    let shareButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        btn.setTitle("Share", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 5
        btn.addTarget(self, action: #selector(handleSharePost), for: .touchUpInside)
        btn.isEnabled = false
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.captionTextView.delegate = self
        self.view.backgroundColor = .white
        
        configureComponents()
        
        //load image
        loadImage()
    }
    
    //MARK: - UITextView
    
    func textViewDidChange(_ textView: UITextView) {
        guard !textView.text.isEmpty else {
            shareButton.isEnabled = false
            shareButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        shareButton.isEnabled = true
        shareButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
    }
    
    //MARK: - Handlers
    
    @objc func handleSharePost() {
        
        guard let caption = captionTextView.text,
            let postImage = photoImageView.image,
            let currentUserID = Auth.auth().currentUser?.uid else {return}
        
        // image upload data
        guard let uploadData = postImage.jpegData(compressionQuality: 0.3) else {return}
        
        // creation date
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        
        let filename = NSUUID().uuidString
        let storageRef = STORAGE_POST_IMAGES_REF.child(filename)
        
        //update storage
        storageRef.putData(uploadData, metadata: nil) { (_ , error) in
            if let error = error {
                print("failed to upload image to storage", error.localizedDescription)
                return
            }
            
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    print("failed to downloading image from storage", error.localizedDescription)
                    return
                }
                
                // image url
                guard let postImageUrl = url?.absoluteString else {return}
                
                // post data
                let values = [
                "caption": caption,
                "creationDate": creationDate,
                "likes": 0,
                "imageUrl": postImageUrl,
                "ownerUid": currentUserID] as [String: AnyObject]
                
                // post id "posts"
                let postId = POSTS_REF.childByAutoId()
                guard let postKey = postId.key else { return }
                
                // upload Info to DB. [for each new post]
                postId.updateChildValues(values) { (error, reference) in
                    
                    //add postId to current user posts
                    USER_POST_REF.child(currentUserID).updateChildValues([postKey: 1])
                    
                    //update user-feed structure
                    self.updateUserFeeds(with: postKey)
                    
                    // upload hashtag to server
                    self.uploadHastagToServer(forPostId: postKey)
                    
                    //upload mention notification to server
                    if caption.contains("@") {
                        self.uploadMentionNotification(forPostId: postKey, withText: caption, isForComment: false)//HERE?
                    }
                    
                    // return to home feed
                    self.dismiss(animated: true) {
                        self.tabBarController?.selectedIndex = 0
                    }
                }
            }
        }
    }
    
    func configureComponents() {
        
        self.view.addSubview(photoImageView)
        photoImageView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: nil, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        
        self.view.addSubview(captionTextView)
        captionTextView.anchor(top: self.view.topAnchor, left: photoImageView.rightAnchor, bottom: nil, right: self.view.rightAnchor, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 100)
        
        self.view.addSubview(shareButton)
        shareButton.anchor(top: photoImageView.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, paddingTop: 12, paddingLeft: 24, paddingBottom: 0, paddingRight: 24, width: 0, height: 40)
        
    }
    
    func loadImage() {
        guard let imageSelected = self.selectedImage else {return}
        self.photoImageView.image = imageSelected
    }
    
    func updateUserFeeds(with postId: String) {
        //current user uid
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        //database values
        let values = [postId: 1]
        //update follower feeds.
        USER_FOLLOWER_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            
            let followerUid = snapshot.key // currentUserId
            //add to user-feed structure, the current user id and posts related
            USER_FEED_REF.child(followerUid).updateChildValues(values)
        }
        //update current user feed
        USER_FEED_REF.child(currentUid).updateChildValues(values)
        
    }
    
    //MARK: - Api
    
    func uploadHastagToServer(forPostId postId: String){
        guard let caption = captionTextView.text else { return }
        let words: [String] = caption.components(separatedBy: .whitespacesAndNewlines)
        
        for var word in words {
            if word.hasPrefix("#"){
                word = word.trimmingCharacters(in: .punctuationCharacters)
                word = word.trimmingCharacters(in: .symbols)
                
                let hashtagValues = [postId: 1]
                HASHTAG_POST_REF.child(word.lowercased()).updateChildValues(hashtagValues)
            }
        }
    }

}
