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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        checkIfUserIsLogged()
        configureViewController()
    }

    func configureViewController(){
        
        //Home Feed VC
        let feedVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootVC: FeedVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //Search VC
        let searchVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootVC: SearchVC())
        
        //Post VC
        let uploadPostVC = constructNavController(unselectedImage:  UIImage(named: "plus_unselected")!, selectedImage: UIImage(named: "plus_unselected")!, rootVC: SearchVC())
        
        //Notifications VC
        let notificationVC = constructNavController(unselectedImage:  UIImage(named: "profile_unselected")!, selectedImage: UIImage(named: "profile_selected")!, rootVC: UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        viewControllers = [feedVC, searchVC, uploadPostVC, notificationVC]
        
        tabBar.tintColor = .black
        
    }
    
    func constructNavController(unselectedImage: UIImage, selectedImage: UIImage, rootVC: UIViewController = UIViewController())->UINavigationController {
        
        let navController = UINavigationController(rootViewController: rootVC)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.navigationBar.tintColor = .black
        return navController
    }
    
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


}
