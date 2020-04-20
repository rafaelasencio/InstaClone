//
//  NotificationsVC.swift
//  Spotsound
//
//  Created by Rafa Asencio on 12/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit

private let reuseIdentifier = "NotificationCell"

class NotificationsVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.separatorColor = .clear
        self.navigationItem.title = "Notifications"
        
        // register cell
        self.tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    //MARK: TableView data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        return cell
    }
}
