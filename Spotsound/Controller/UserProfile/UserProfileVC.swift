//
//  UserProfileVC.swift
//  Spotsound
//
//  Created by Rafa Asencio on 12/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "cellId"
private let userProfileHeaderCell = "UserProfileHeaderCell"

class UserProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    
    var user: User?
    
    override func viewDidLoad() {
        self.collectionView.backgroundColor = .white
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(UserProfileHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: userProfileHeaderCell)
        
        fetchCurrentUserData()
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: userProfileHeaderCell, for: indexPath) as! UserProfileHeaderCell
        
        // set user property in UserProfileHeaderCell
        let currentUserUid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(currentUserUid!).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictValues = snapshot.value as? Dictionary<String, AnyObject> else {return}
            
            let uid = snapshot.key
            let user = User(uid: uid, dict: dictValues)
            self.navigationItem.title = user.username
            header.user = user
        }
        
        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    func fetchCurrentUserData(){
                
        
    }

}
