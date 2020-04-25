//
//  FeedVC.swift
//  Spotsound
//
//  Created by Rafa Asencio on 12/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit
import Firebase
import ActiveLabel

private let identifier = "cellId"

class FeedVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, FeedCellDelegate {

    
    //MARK: - Properties
    
    var posts = [Post]()
    var viewSinglePost = false
    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = .white

        self.collectionView.register(FeedCell.self, forCellWithReuseIdentifier: identifier)
        
        // configure refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.collectionView.refreshControl = refreshControl
        configureNavigationBar()
        
        // fetch post 
        if !viewSinglePost {
            fetchPost()
        }
        
        // update user feed
        updateUserFeeds()
    }
    
    
    //MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.view.frame.width
        var height = width + 8 + 40 + 8 //56 for FeedCell
        height += 50 //space for stackView
        height += 60 //space for caption
        return CGSize(width: width, height: height)
    }
    
    
    //MARK: - Datasource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return viewSinglePost ?  1 : posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! FeedCell
        cell.delegate = self
        
        if viewSinglePost {
            if let post = self.post {
                cell.post = post
            }
        } else {
            cell.post = posts[indexPath.row]
        }
        
        handleHastagTapped(forCell: cell)
        handleUsernameLabelTappped(forCell: cell)
        handleMentionTapped(forCell: cell)
        return cell
    }
    
    
    func configureNavigationBar(){
        
        if !viewSinglePost {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        }
        
        self.navigationItem.title = "Feed"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send2"), style: .plain, target: self, action: #selector(handleShowMessages))
    }
    
    //MARK: - FeedCellDelegate
    
    func handleUsernameTapped(for cell: FeedCell) {
        
        guard let post = cell.post else {return}
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = post.user
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    func handleOptionsTapped(for cell: FeedCell) {
        print("options")
    }
    
    func handleLikeTapped(for cell: FeedCell, isDoubleTap: Bool) {
        
        guard let post = cell.post else {return}
        
        if post.didLike {
            // handle unlike post
            if !isDoubleTap {
                post.adjustLikes(addLike: false) { (likes) in
                    cell.likesLabel.text = "\(likes) likes"
                    cell.likeButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
                }
            }
        } else {
            // handle like post
            post.adjustLikes(addLike: true) { (likes) in
                cell.likesLabel.text = "\(likes) likes"
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
            }
            
        }
    }
    
    func handleShowLikes(for cell: FeedCell) {
        
        guard let post = cell.post else {return}
        guard let postId = post.postId else {return}
        let followLikeCell = FollowLikeVC()
        followLikeCell.viewingMode = FollowLikeVC.ViewingMode(index: 2)
        followLikeCell.postId = postId
        self.navigationController?.pushViewController(followLikeCell, animated: true)
        
    }
    
    func handleConfigureLikeButton(for cell: FeedCell) {
        guard let post = cell.post else {return}
        guard let postId = post.postId else {return}
        guard let currentUserUid = Auth.auth().currentUser?.uid else {return}
        
        USER_LIKES_REF.child(currentUserUid).observe(.value) { (snapshot) in
            
            // check if post id exists in user-likes structure
            if snapshot.hasChild(postId) {
                post.didLike = true
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
            } else {
                post.didLike = false
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
            }
        }
    }
    
    
    func handleCommentTapped(for cell: FeedCell) {
        guard let post = cell.post else {return}
        let commentVC = CommentVC(collectionViewLayout: UICollectionViewFlowLayout())
        commentVC.post = post
        self.navigationController?.pushViewController(commentVC, animated: true)
    }
    
    //MARK: - Handlers
    
    func handleHastagTapped(forCell cell: FeedCell){
        cell.captionLabel.handleHashtagTap { (hashtag) in
            let hashtagController = HashtagController(collectionViewLayout: UICollectionViewFlowLayout())
            hashtagController.hashtag = hashtag.lowercased()
            self.navigationController?.pushViewController(hashtagController, animated: true)
        }
    }
    
    func handleMentionTapped(forCell cell: FeedCell){
        cell.captionLabel.handleMentionTap { (username) in
            self.getMentionedUser(withUsername: username)
        }
    }
    
    func handleUsernameLabelTappped(forCell cell: FeedCell){
        guard let user = cell.post?.user else { return }
        guard let username = user.username else { return }
        let customType = ActiveType.custom(pattern: "^\(username)\\b")
        
        cell.captionLabel.handleCustomTap(for: customType) { (_) in
            let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
            self.navigationController?.pushViewController(userProfileVC, animated: true)
            userProfileVC.user = user
        }
    }
    
    @objc func handleRefresh(){
        posts.removeAll(keepingCapacity: false)
        fetchPost()
        self.collectionView.reloadData()
    }
    
    @objc func handleShowMessages() {
        let messagesController = MessagesController()
        self.navigationController?.pushViewController(messagesController, animated: true)
    }
    
    @objc func handleLogout(){
        print("log out..")
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (action) in
            do {
                try Auth.auth().signOut()
                
                let navController = UINavigationController(rootViewController: LoginVC())
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
                
                print("Log out successfully")
            } catch let error {
                print("failed sign out", error.localizedDescription)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Api
    
    func updateUserFeeds() {
        
        guard let currentUserUid = Auth.auth().currentUser?.uid else {return}
        
        USER_FOLLOWING_REF.child(currentUserUid).observe(.childAdded) { (snapshot) in
            let followingUserId = snapshot.key
            USER_POST_REF.child(followingUserId).observe(.childAdded) { (snapshot) in
                let postId = snapshot.key
                //add on "user-feed" the currentUserId with posts of followed users
                USER_FEED_REF.child(currentUserUid).updateChildValues([postId : 1])
            }
        }
        USER_POST_REF.child(currentUserUid).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            USER_FEED_REF.child(currentUserUid).updateChildValues([postId : 1])
        }
    }
    func fetchPost(){
        
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        USER_FEED_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            
            let postId = snapshot.key
            
            Database.fetchPost(with: postId) { (post) in
                self.posts.append(post)
                self.posts.sort(by: {$0.creationDate > $1.creationDate})
                
                // stop refreshing
                self.collectionView.refreshControl?.endRefreshing()
                
                self.collectionView.reloadData()
            }
        }
    }

}
