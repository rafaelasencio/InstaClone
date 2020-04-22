//
//  ChatController.swift
//  Spotsound
//
//  Created by Rafa Asencio on 23/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import Foundation
import UIKit
import Firebase


private let reuseIdentifier = "ChatCell"

class ChatController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    //Mark: - Properties
    
    var user: User?
    var messages = [Message]()
    
    //MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //register cell
        self.collectionView.register(ChatCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.backgroundColor = .white
        
        // configure navigation bar
        configureNavigationBar()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - UICollectionView
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        return cell
    }
    
    //MARK: - Handlers
    
    @objc func handleInfoTapped(){
        print("handle info")
    }
    
    func configureNavigationBar(){
        guard let user = self.user else { return }
        navigationItem.title = user.username
        let infoButton = UIButton(type: .infoLight)
        infoButton.tintColor = .black
        infoButton.addTarget(self, action: #selector(handleInfoTapped), for: .touchUpInside)
        
        let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
        navigationItem.rightBarButtonItem = infoBarButtonItem
    }
    
    
    
}
