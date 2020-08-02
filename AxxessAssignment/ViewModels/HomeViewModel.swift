//
//  HomeViewModel.swift
//  AxxessAssignment
//
//  Created by Sushant Alone on 02/08/20.
//  Copyright © 2020 Sushant Alone. All rights reserved.
//

import Foundation
import Kingfisher
import RealmSwift
import UIKit

let defaultImage = UIImage(named: "placeholder")

class HomeViewModel {
    var homeImageData = Observable<[ItemDataModel]> (value : [])
    var homeTextData = Observable<[ItemDataModel]> (value : [])
    var isLoading = Observable<Bool> (value: true)
    var isOnline : Bool = true
    private var collection : UICollectionView
    let container : Container = try! Container()
    var imageCounter = 0
    init(with collectionView:UICollectionView , isOnline : Bool) {
        self.collection = collectionView
        self.isOnline = isOnline
    }
    
    func getNumberOfSections() -> Int {
        return 2
    }
    
    func getUIEgdeInsets() -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    
    func getHomeData() {
        homeImageData.value = []
        if isOnline {
            ImageCache.default.clearDiskCache()
        }
        APIClient.getHomeData { (dataModel) in
            switch dataModel{
            case .success(let homeResponse):
                self.updateRealm(homeResponse)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func updateRealm(_ itemArray:[ItemDataModel]) {
        let totalImages = itemArray.filter{$0.type == .image}.count
        for item in itemArray{
            var tempItem = item
            switch tempItem.type {
            case .image:
                tempItem.downloadAndSaveImage {  size in
                    tempItem.imgWidth = Double(size.width)
                    tempItem.imgHeight = Double(size.height)
                    try! self.container.write { transaction in
                        transaction.add(tempItem)
                    }
                    self.imageCounter = self.imageCounter + 1
                    if self.imageCounter == totalImages{
                        self.isLoading.value = false
                        self.fetchFromRealm(with: "image")
                    }
                }
                
            case .text:
                if let itemData = item.data, itemData.count > 0, let _ = item.date {
                try! self.container.write { transaction in
                    transaction.add(tempItem)
                    }
                }
            default:
                print("")
            }
            
        }
        
    }
    
    func fetchFromRealm(with type:String){
        let imagePredicate = NSPredicate(format: "dataType == %@", type)
        let itemObjects = self.container.fetchData(with: imagePredicate, classObject: ItemObject.self)
        
        let textPredicate = NSPredicate(format: "dataType == %@", "text")
        let textItemObjects = self.container.fetchData(with: textPredicate, classObject: ItemObject.self)
        
        var imgArr : [ItemDataModel] = []
        var textArr : [ItemDataModel] = []
            
        
        for itemObject in itemObjects {
            let item = ItemDataModel(managedObject: itemObject as! ItemObject)
            imgArr.append(item)
        }
        
        imgArr = imgArr.sorted(by: { (item1, item2) -> Bool in
            return item1.getGridHeight(collectionView: self.collection) > item2.getGridHeight(collectionView: self.collection)
        })
        homeImageData.value = imgArr
        
        for textObject in textItemObjects {
            let item = ItemDataModel(managedObject: textObject as! ItemObject)
            textArr.append(item)
        }
        
        homeTextData.value = textArr
        
    }
    
    func fetchImageDataFromRealm() -> [ItemDataModel] {
        let imagePredicate = NSPredicate(format: "dataType == %@", "image")
        let itemObjects = self.container.fetchData(with: imagePredicate, classObject: ItemObject.self)
        var imgArr : [ItemDataModel] = []
        for itemObject in itemObjects {
            let item = ItemDataModel(managedObject: itemObject as! ItemObject)
            imgArr.append(item)
        }
        imgArr = imgArr.sorted(by: { (item1, item2) -> Bool in
            return item1.getGridHeight(collectionView: self.collection) > item2.getGridHeight(collectionView: self.collection)
        })
        return imgArr
    }
    
    func fetchTextDataFromRealm() -> [ItemDataModel] {
        let textPredicate = NSPredicate(format: "dataType == %@", "text")
        let textItemObjects = self.container.fetchData(with: textPredicate, classObject: ItemObject.self)
        var textArr : [ItemDataModel] = []
        for textObject in textItemObjects {
            let item = ItemDataModel(managedObject: textObject as! ItemObject)
            textArr.append(item)
        }
        return textArr
    }

}


struct ItemDataModel : Codable,RowViewModel {
    let id : String
    let type : DataType
    let date : String?
    let data : String?
    var imgWidth : Double?
    var imgHeight : Double?
    
    func cellIdentifier() -> String {
        var cellIdentifier : String
        switch self.type {
        case .image:
            cellIdentifier = ImageGrid.cellIdentifier()
        default:
            cellIdentifier = TextGrid.cellIdentifier()
        }
        return cellIdentifier
    }
    
    func getImageUrl() ->URL?{
        if let image = self.data {
            return URL.init(string:image)
        }
        return nil
    }
    
    func getGridSize(size : CGSize) -> CGSize {
        switch type {
        case .image:
            let width = (size.width - 40) / 2

            if Float(self.imgWidth ?? 0) > Float(self.imgHeight ?? 0) {
                return CGSize.init(width: width, height: (width/CGFloat(self.imgWidth ?? 0)) * CGFloat(self.imgHeight ?? 0))
            } else {
                return CGSize.init(width: width, height: (width/CGFloat(self.imgWidth ?? 0)) * CGFloat(self.imgHeight ?? 0))
            }
        default:
            return CGSize.init(width: 100, height: 100)
        }
        
        
    }
    
    
    
    func getGridHeight(collectionView : UICollectionView) -> CGFloat {
        let insets = collectionView.contentInset
        let width =  (collectionView.bounds.width  - (insets.left + insets.right))/2
        switch type {
        case .image:
            let height = (CGFloat(imgHeight ?? 0.0))*(width/CGFloat(imgWidth ?? 0.0))
            return  height
        default:
            return width
        }
        
        
    }
    
    func downloadAndSaveImage(_ afterDownload : @escaping (CGSize) -> Void) {
        if let url = getImageUrl(){
            let cache = ImageCache.default
//            if !cache.isCached(forKey: data ?? ""){
                KingfisherManager.shared.downloader.downloadTimeout = 600
                KingfisherManager.shared.retrieveImage(with: url) { (result) in
                    switch result {
                    case .success(let value):
                        cache.store(value.image, forKey: self.data ?? "")
//                        print("Image size : \(value.image.size)")
                        afterDownload(value.image.size)
                        
                    case .failure(let error):
                        afterDownload(defaultImage!.size)
                        print(error)
                        
                    }
                    
                }
                
//            }else{
//                if type == .image{
//                    cachedImage { (image) in
//                        if let image = image {
//                            afterDownload(image.size)
//                        }else{
//                            let mainWidth = UIScreen.main.bounds.size.width - 20
//                            let defaultSize = CGSize(width: mainWidth/2, height: mainWidth/2)
//                            afterDownload(defaultSize)
//                        }
//
//                    }
//                }else{
//                    afterDownload(.zero)
//                }
//
//            }
            
        }
        
    }
    
    func cachedImage(_ afterCompletion : @escaping (UIImage?)->Void){
       let cache = ImageCache.default
        cache.retrieveImage(forKey: data ?? "") { (result) in
            switch result {
            case .success(let value):
                afterCompletion(value.image)
            case .failure(let error):
                afterCompletion(defaultImage!)
                print(error)
                
            }
        }
    }
}
