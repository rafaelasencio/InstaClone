//
//  SelectImageVC.swift
//  Spotsound
//
//  Created by Rafa Asencio on 15/04/2020.
//  Copyright © 2020 Rafa Asencio. All rights reserved.
//

import UIKit
import Photos

private let reuserIdentifier = "SelectPhotoCell"
private let headerIdentifier = "SelectPhotoHeader"

class SelectImageVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    
    //MARK: - Properties
    
    var images = [UIImage]()
    var assets = [PHAsset]()
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(SelectPhotoCell.self, forCellWithReuseIdentifier: reuserIdentifier)
        collectionView.register(SelectPhotoHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        collectionView.backgroundColor = .white
        //conf nav buttons
        configureNavigationButtons()
        //fetch photos
        fetchPhotos()
    }

    //MARK: - UICollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let width = self.view.frame.width
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // set size for cells
        let width = (self.view.frame.width - 3) / 4 //-3 for spacing
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    
    //MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuserIdentifier, for: indexPath) as! SelectPhotoCell
        
        cell.photoImageView.image = images[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! SelectPhotoHeader
        
        if let selectedImage = self.selectedImage {
            //index selected images
            if let index = self.images.firstIndex(of: selectedImage) {
                //asset associated with selected image
                let selectedAsset = self.assets[index]
                let imageManager = PHImageManager.default() //return shared image manager object
                let targetSize = CGSize(width: 600, height: 600)
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .default, options: nil) { (image, info) in
                    header.photoImageView.image = image
                }
            }
        }
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.selectedImage = images[indexPath.row]
        self.collectionView.reloadData()
        
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    //MARK: - Handlers
    
    @objc func handleCancel(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleNext(){
           print("handle next..")
       }
    
    func configureNavigationButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }
    
    func getAssetFetchOptions() -> PHFetchOptions{
        let options = PHFetchOptions()
        //fetch limit and order by creation date
        options.fetchLimit = 30
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        options.sortDescriptors = [sortDescriptor]
        return options
    }
    
    func fetchPhotos() {
        
        // grab all images in application
        let allPhotos = PHAsset.fetchAssets(with: .image, options: getAssetFetchOptions())
        
        print("function is running")
        
        //fetch image on background thread
        DispatchQueue.global(qos: .background).async {
            //enumerate objects of fecth result
            allPhotos.enumerateObjects { (asset, count, stop) in
                 
                let imageManager = PHImageManager.default() //return shared image manager object
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true //to fetch in order
                
                //request image representation for specified asset
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, info) in
                    if let image = image {
                        //append image to data source
                        self.images.append(image)
                        //append asset to data source
                        self.assets.append(asset)
                        //set selected image with first result
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                        //reload collectionView images once count has completed
                        if count == allPhotos.count - 1 {
                            //reload in main thread
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                            
                        }
                        
                    }
                }
            }
        }
    }
    
    
    
    
}
