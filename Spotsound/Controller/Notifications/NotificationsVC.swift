//
//  NotificationsVC.swift
//  Spotsound
//
//  Created by Rafa Asencio on 12/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit
import Firebase


private let reuseIdentifier = "NotificationCell"

class NotificationsVC: UITableViewController {

    //MARK: - Properties
    var notifications = [Notification]()
    var timer: Timer?
    var currentKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.separatorColor = .clear
        self.navigationItem.title = "Notifications"
        
        // register cell
        self.tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // fetch notifications
        fetchNotification()
    }
    
    //MARK: TableView data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if notifications.count > 4 {
            if indexPath.item == notifications.count - 1 {
                fetchNotification()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        cell.notification = notifications[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = notification.user
        self.navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    //MARK_ - Handlers
    
    func handleReloadTable(){
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleSortNotifications), userInfo: nil, repeats: false)
    }
    
    @objc func handleSortNotifications(){

        self.notifications.sort(by: {$0.creationDate > $1.creationDate})
        self.tableView.reloadData()
    }
    
    
    //MARK: - Api
    
    func fetchNotifications(withNotificationId notificationId: String, dataSnapshot snapshot: DataSnapshot){
        
        guard let currentUserUid = Auth.auth().currentUser?.uid else {return}
        guard let dictionary = snapshot.value as? Dictionary <String, AnyObject> else {return}
        guard let uid = dictionary["uid"] as? String else {return}
        
        Database.fetchUser(with: uid) { (user) in
            
            // if notification is for post
            if let postId = dictionary["postId"] as? String {
                
                Database.fetchPost(with: postId) { (post) in
                    let notification = Notification(user: user, post: post, dictionary: dictionary)
                    self.notifications.append(notification)
                    self.handleReloadTable()
                }
            } else {
                
                let notification = Notification(user: user, dictionary: dictionary)
                self.notifications.append(notification)
                self.handleReloadTable()
            }
        }
        
        NOTIFICATIONS_REF.child(currentUserUid).child(notificationId).child("check").setValue(1)
    }
    
    func fetchNotification(){
        
        guard let currentUserUid = Auth.auth().currentUser?.uid else {return}
        
        if currentKey == nil {
            
            // .childAdded go through each notification
            NOTIFICATIONS_REF.child(currentUserUid).queryLimited(toLast: 5).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach { (snapshot) in
                    let notificationId = snapshot.key
                    self.fetchNotifications(withNotificationId: notificationId, dataSnapshot: snapshot)
                }
                self.currentKey = first.key
            }
        } else {
            NOTIFICATIONS_REF.child(currentUserUid).queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 6).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach { (snapshot) in
                    let notificationId = snapshot.key
                    
                    if notificationId != self.currentKey {
                        self.fetchNotifications(withNotificationId: notificationId, dataSnapshot: snapshot)
                    }
                }
                self.currentKey = first.key
                
            }
        }
    }
    
    
}

extension NotificationsVC: NotificationCellDelegate {
    
    //MARK: - NotificationCellDelegate
    func handleFollowTapped(for cell: NotificationCell) {
        guard let user = cell.notification?.user else { return }
        
        if user.isFollowed {
            // handle unfollow user
            user.unfollow()
            cell.followButton.configure(didFollow: false)
        } else {
            // handle follow user
            user.follow()
            cell.followButton.configure(didFollow: true )
        }
    }
    
    func handlePostTapped(for cell: NotificationCell) {
        
        guard let post = cell.notification?.post else { return }
        let feedController = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        feedController.viewSinglePost = true
        feedController.post = post
        self.navigationController?.pushViewController(feedController, animated: true)
    }
    
    
}
