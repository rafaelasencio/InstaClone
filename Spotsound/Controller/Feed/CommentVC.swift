//
//  CommentVC.swift
//  Spotsound
//
//  Created by Rafa Asencio on 19/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit
import Firebase


private let reuseIdentifier = "CommentCell"

class CommentVC: UICollectionViewController,UICollectionViewDelegateFlowLayout {
    
    //MARK: - Properties
    var comments = [Comment]()
    var post: Post?
    
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        containerView.addSubview(postButton)
        postButton.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 50, height: 0)
        postButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true

        containerView.addSubview(commentTextField)
        commentTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: postButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        let dividerView = UIView()
        dividerView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        containerView.addSubview(dividerView)
        dividerView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: postButton.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
        
        return containerView
    }()
    
    let commentTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter comment.."
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()
    
    let postButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Post", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.addTarget(self, action: #selector(handleUploadComment), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure collectionView
        self.collectionView.backgroundColor = .white
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.keyboardDismissMode = .interactive
        self.collectionView.contentInset = UIEdgeInsets(top:  0, left: 0, bottom: -50, right: 0)
        self.collectionView.scrollIndicatorInsets = UIEdgeInsets(top:  0, left: 0, bottom: -50, right: 0)
        
        //navigation title
        self.navigationItem.title = "Comments"
        
        //register cell
        self.collectionView.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        //fetch comments
        fetchComments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    //MARK: - UICollectionView
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.row]
        dummyCell.layoutIfNeeded() // adjust the size
        
        let targetsize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetsize)
        
        let height = max(40 + 8 + 8, estimatedSize.height)
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
        cell.comment = comments[indexPath.item]
        return cell
    }
    
    //MARK: - Handlers
    
    @objc func handleUploadComment(){
        print("handle comments")
        guard let postId = self.post?.postId else {return}
        guard let commentText = commentTextField.text else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let creationDate = Int(NSDate().timeIntervalSince1970)
        let values = [
            "commentText":commentText,
            "creationDate":creationDate,
            "uid":uid] as [String:Any]
        COMMENT_REF.child(postId).childByAutoId().updateChildValues(values) { (error, ref) in
            self.uploadCommentNotificationToServer()
            // clean textfield after upload post
            self.commentTextField.text = nil
        }
    }
    
    func fetchComments(){

        guard let postId = self.post?.postId else {return}
        
        COMMENT_REF.child(postId).observe(.childAdded) { (snapshot) in
            
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return}
            
            guard let uid = dictionary["uid"] as? String else {return}
            
            Database.fetchUser(with: uid) { (user) in
                
                let comment = Comment(user: user, dictionary: dictionary)
                self.comments.append(comment)
                self.collectionView.reloadData()
            }
            
        }
    }
    
    func uploadCommentNotificationToServer(){
        
        guard let currentUserUid = Auth.auth().currentUser?.uid else {return}
        guard let postId = self.post?.postId else {return}
        guard let uid = self.post?.user.uid else {return}
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        // notification values
        let values = [
            "check": 0,
            "creationDate":creationDate,
            "uid": currentUserUid,
            "type": COMMENT_INT_VALUE,
            "postId":postId] as [ String : Any ]
        
        // upload comment notification to server
        if uid != currentUserUid {
            NOTIFICATIONS_REF.child(uid).childByAutoId().updateChildValues(values)
        }
        
    }
    
    
}
