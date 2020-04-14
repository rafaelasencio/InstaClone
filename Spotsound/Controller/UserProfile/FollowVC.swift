//
//  FollowVC.swift
//  Spotsound
//
//  Created by Rafa Asencio on 14/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit

private let reuseIdentifier = "FollowCell"

class FollowVC: UITableViewController {
    
    //MARK: - Properties
    var viewFollowers = false
    var viewFollowing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //register cell
        tableView.register(FollowCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        //configure nav
        if viewFollowers {
            navigationItem.title = "Followers"
        } else {
            navigationItem.title = "Following"
        }
        tableView.separatorColor = .clear
    }
    
    //MARK: - TableView
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FollowCell
        return cell
    }
    
    func fetchUsers(){
        
        if viewFollowers {
            //fetch followers
            
        } else {
            //fetch following user
            
        }
    }
}
