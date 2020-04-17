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

class FeedVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    
    //MARK: - Properties
    
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = .white

        self.collectionView.register(FeedCell.self, forCellWithReuseIdentifier: identifier)
        
        configureNavigationBar()
        
        // fetchPost
        fetchPost()
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
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! FeedCell
        
        cell.post = posts[indexPath.row]
        
        return cell
    }
    
    
    func configureNavigationBar(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        self.navigationItem.title = "Feed"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send2"), style: .plain, target: self, action: #selector(handleShowMessages))
    }
    
    //MARK: - Handlers
    
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
    
    func fetchPost(){
        
        POSTS_REF.observe(.childAdded) { (snapshot) in
            
            let postId = snapshot.key
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return}
            
            let post = Post(postId: postId, dicctionary: dictionary)
            self.posts.append(post)
            self.posts.sort(by: {$0.creationDate > $1.creationDate})
            
            self.collectionView.reloadData()
        }
    }

}
