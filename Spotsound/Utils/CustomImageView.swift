//
//  CustomImageView.swift
//  Spotsound
//
//  Created by Rafa Asencio on 13/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//


import UIKit

var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    

    var lastImgUrlUsedToLoadImage: String?
    
    
    func loadImage(with urlString: String){
        
        // set image to nil
        self.image = nil
        
        // set lastImgUrlUsedToLoadImage
        lastImgUrlUsedToLoadImage = urlString
        
        //check if image exist in cache
        if let imageCache = imageCache[urlString] {
            self.image = imageCache
            return
        }
        
        guard let url = URL(string: urlString) else {return}
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                print("Failed load user profile image", error.localizedDescription)
                return
            }
            
            // return if url to load image not equal post image url
            if self.lastImgUrlUsedToLoadImage != url.absoluteString {
                return
            }
            
            guard let data = data else {return}
            let photoImage = UIImage(data: data)
            imageCache[url.absoluteString] = photoImage
            
            DispatchQueue.main.async {
                self.image = photoImage
            }
            return
            
        }.resume()
    }

}
