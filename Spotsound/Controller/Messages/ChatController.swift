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
    
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 55)
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        containerView.addSubview(sendButton)
        
        sendButton.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        containerView.addSubview(messagesTextfield)
        messagesTextfield.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: sendButton.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 4, width: 0, height: 0)
        
        let separatorView = UIView()
        separatorView.backgroundColor = .lightGray
        containerView.addSubview(separatorView)
        separatorView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
       
        
        return containerView
    }()
    
    let messagesTextfield: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter Message"
        return tf
    }()
    
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
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    //MARK: - UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width / 2, height: 50)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChatCell
        return cell
    }
    
    //MARK: - Handlers
    
    @objc func handleSend(){
        print("handle send")
    }
    
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
