//
//  NewMessagesController.swift
//  Spotsound
//
//  Created by Rafa Asencio on 22/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit
import Firebase


private let reuseIdentifier = "NewMessageCell"

class NewMessagesController: UITableViewController {
    
    //MARK: - Properties
    var users = [User]()
    var messagesController: MessagesController?
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure navigation bar
        configureNavigationBar()
        
        // register cell
        tableView.register(NewMessageCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        //fetch users
        fetchUsers()
    }
    
    //MARK: - UITableView
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NewMessageCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messagesController?.showChatController(for: user)
        }
    }
    
    
    //MARK: - Handlers
    
    @objc func handleCancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func configureNavigationBar(){
        navigationItem.title = "New Message"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    //MARK: - Api
    
    func fetchUsers() {
        USER_REF.observe(.childAdded) { (snapshot) in
            
            let uid = snapshot.key
            
            if uid != Auth.auth().currentUser?.uid {
                
                Database.fetchUser(with: uid) { (user) in
                    self.users.append(user)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
}
