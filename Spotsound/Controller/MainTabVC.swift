//
//  MainTabVC.swift
//  Spotsound
//
//  Created by Rafa Asencio on 12/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit
import Firebase


class MainTabVC: UITabBarController, UITabBarControllerDelegate  {

    //MARK: - Properties
    let dot = UIView()
    var notificationsId = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        // configure view controllers
        configureViewController()
        
        // configure notification dot
        configureNotificationDot()
        
        // observe notifications
        observeNotification()
        
        // check user validation
        checkIfUserIsLogged()
    }

    func configureViewController(){
        
        //Home Feed VC
        let feedVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootVC: FeedVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //SearchVC
        let searchVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootVC: SearchVC())
        
        //SelectImageVC
        let selectImageVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"))
        
        //NotificationsVC
        let notificationVC = constructNavController(unselectedImage:  #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"), rootVC: NotificationsVC())
        
        //UserProfileVC
        let userProfileVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"), rootVC: UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        viewControllers = [feedVC, searchVC, selectImageVC, notificationVC, userProfileVC]
        
        tabBar.tintColor = .black
    }
    
    //MARK: - UITabController
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        
        if index == 2 {
            let selectImageVC = SelectImageVC(collectionViewLayout: UICollectionViewFlowLayout())
            let navController = UINavigationController(rootViewController: selectImageVC)
            navController.modalPresentationStyle = .fullScreen
            navController.navigationBar.tintColor = .black

            self.present(navController, animated: true, completion: nil)
            return false
        } else if index == 3 {
            dot.isHidden = true
            return true
        }
        return true
    }

    //MARK: - Handlers
    
    func constructNavController(unselectedImage: UIImage, selectedImage: UIImage, rootVC: UIViewController = UIViewController())->UINavigationController {
        
        let navController = UINavigationController(rootViewController: rootVC)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.navigationBar.tintColor = .black
        return navController
    }
    
    func configureNotificationDot(){
        
        // determinate device used
        if UIDevice().userInterfaceIdiom == .phone {
            
            let tabBarHeight = tabBar.frame.height
            if UIScreen.main.nativeBounds.height == 2688 {
                // configure dot for iPhone X
                dot.frame = CGRect(x: view.frame.width / 5 * 3, y: view.frame.height - tabBarHeight, width: 6, height: 6)
            } else {
                // configure for other models
                dot.frame = CGRect(x: view.frame.width / 5 * 3, y: view.frame.height - 16, width: 6, height: 6)
            }
            
            // create the dot
            dot.center.x = (view.frame.width / 5 * 3 + (view.frame.width / 5 ) / 2 )
            dot.backgroundColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1)
            dot.layer.cornerRadius = dot.frame.width / 2
            self.view.addSubview(dot)
            dot.isHidden = true
        }
    }
    
    //MARK: - Api
    
    func checkIfUserIsLogged(){
        if Auth.auth().currentUser == nil {
            print("not registered")
            DispatchQueue.main.async {
                let navController = UINavigationController(rootViewController: LoginVC())
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }
        }
    }
    
    func observeNotification(){
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        // clean array before start appending
        self.notificationsId.removeAll()
        
        NOTIFICATIONS_REF.child(currentUserUid).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
            
            allObjects.forEach {(snapshot) in
                let notificationId = snapshot.key
                
                NOTIFICATIONS_REF.child(currentUserUid).child(notificationId).child("check").observeSingleEvent(of: .value) { (snapshot) in
                    
                    guard let check = snapshot.value as? Int else { return }
                    // add notifications not checked to the array
                    if check == 0 {
                        self.dot.isHidden = false
                    } else {
                        self.dot.isHidden = true
                    }
                }
            }
        }
    }
    


}
