//
//  FeedVC.swift
//  Spotsound
//
//  Created by Rafa Asencio on 12/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit
import Firebase

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
    
    func handleLikeTapped(for cell: FeedCell) {
        print("liked")
    }
    
    func handleCommentTapped(for cell: FeedCell) {
        print("comment")
    }
    
    //MARK: - Handlers
    @objc func handleRefresh(){
        posts.removeAll(keepingCapacity: false)
        fetchPost()
        self.collectionView.reloadData()
    }
    
    @objc func handleShowMessages() {
        print("handle show message")
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
