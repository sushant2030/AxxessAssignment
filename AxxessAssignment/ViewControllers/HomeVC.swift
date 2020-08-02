//
//  HomeVC.swift
//  AxxessAssignment
//
//  Created by Sushant Alone on 02/08/20.
//  Copyright © 2020 Sushant Alone. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher
import Reachability
class HomeVC: UIViewController {
    
    
    lazy var homeCollectionView : UICollectionView = {
        let layout = CustomLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.collectionViewLayout = layout
        return collection
    }()
    var reachability: Reachability!
    var homeViewModel : HomeViewModel?
    var isLoaded = false
    
    override func viewDidLoad() {
        
        /*It is Observed that everytime the api was getting hit for the image, a different image used to
         get load so I had to clean the cache on each launch when the network is Reachable else offline
         content can be seen.
         Another thing is we were not getting the Image sizes initially so I have downloaded all the images
         before I could show the content.
         However, in offline mode, application will be launched quickly.
         */
        
        super.viewDidLoad()
        view.addSubview(homeCollectionView)
        view.backgroundColor = .white
        if let layout = homeCollectionView.collectionViewLayout as? CustomLayout{
            layout.delegate = self
        }
        checkReachability()
        self.navigationItem.title = "Home"
    }
    
    func proceed()  {
        installAndRegisterUI()
        bindData()
        self.homeViewModel!.getHomeData()
    }
    
    func checkReachability()  {
        do {
            try reachability = Reachability()
            NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged(_:)), name: Notification.Name.reachabilityChanged, object: reachability)
            try reachability.startNotifier()
        } catch {
            print("This is not working.")
        }
    }
    
    func installAndRegisterUI() {
        
        homeCollectionView.delegate = self
        homeCollectionView.dataSource = self
        homeCollectionView.register(TextGrid.self, forCellWithReuseIdentifier: TextGrid.cellIdentifier())
        homeCollectionView.register(ImageGrid.self, forCellWithReuseIdentifier: ImageGrid.cellIdentifier())
        homeCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(self.view.snp.leading)
            make.trailing.equalTo(self.view.snp.trailing)
            make.bottom.equalTo(self.view.snp.bottom)
        }
    }
    
    func bindData()  {
        homeViewModel!.homeImageData.addObserver(fireNow: false) { (itemVM) in
            DispatchQueue.main.async {
                
                self.homeCollectionView.reloadData()
                self.homeCollectionView.isHidden = false
            }
        }
        homeViewModel!.homeTextData.addObserver(fireNow: false) { (itemVM) in
            DispatchQueue.main.async {
                self.homeCollectionView.reloadData()
                self.homeCollectionView.isHidden = false
            }
        }
        
        homeViewModel!.isLoading.addObserver {[weak self] isLoading in
            DispatchQueue.main.async {
                if (isLoading){
                    self?.view.activityStartAnimating(activityColor: UIColor.white, backgroundColor: UIColor.black.withAlphaComponent(0.5))
                    self?.homeCollectionView.isHidden = true
                }
                else{
                    self?.view.activityStopAnimating()
                }
            }
        }
    }
    
    override func updateViewConstraints() {
        
        super.updateViewConstraints()
    }
    
    @objc func reachabilityChanged(_ note: NSNotification) {
        let reachability = note.object as! Reachability
        self.homeViewModel = HomeViewModel.init(with: homeCollectionView, isOnline: (reachability.connection != .unavailable))
        proceed()
    }
    
}

extension HomeVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemModelVM = (indexPath.section == 0) ? homeViewModel!.homeImageData.value[indexPath.row] : homeViewModel!.homeTextData.value[indexPath.row]
        return itemModelVM.getGridSize(size: collectionView.bounds.size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return homeViewModel!.getUIEgdeInsets()
    }
    
}

extension HomeVC : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let homeVM = homeViewModel{
            return homeVM.getNumberOfSections()
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (section == 0) ? homeViewModel!.homeImageData.value.count : homeViewModel!.homeTextData.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemModelVM = (indexPath.section == 0) ?  homeViewModel!.homeImageData.value[indexPath.row] : homeViewModel!.homeTextData.value[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemModelVM.cellIdentifier(), for: indexPath)
//        print("Index \(indexPath.row), url : \(itemModelVM.data!)")
        if let cell = cell as? CellConfigurable{
            cell.setup(viewModel: itemModelVM)
            cell.setupUI()
        }
        cell.backgroundColor = .white
        return cell
    }
    
    
}

extension HomeVC : CustomLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let itemModelVM = (indexPath.section == 0) ? homeViewModel!.homeImageData.value[indexPath.row] : homeViewModel!.homeTextData.value[indexPath.row]
        return itemModelVM.getGridHeight(collectionView: collectionView)
    }
    
    
}

extension HomeVC : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let imageVC = ImageVC()
            let model = homeViewModel!.homeImageData.value[indexPath.row]
            let cache = ImageCache.default
            if cache.isCached(forKey: model.data ?? ""){
                model.cachedImage { (image) in
                    imageVC.fullScreenImageView.image = image
                    self.navigationController?.pushViewController(imageVC, animated: true)
                }
            }
            
        default:
            let textVC = TextVC()
            let model = homeViewModel!.homeTextData.value[indexPath.row]
            if let text = model.data {
                textVC.textView.text = text
                self.navigationController?.pushViewController(textVC, animated: true)
            }
        }
        
    }
}
