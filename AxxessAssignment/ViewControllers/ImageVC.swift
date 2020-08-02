//
//  ImageVC.swift
//  AxxessAssignment
//
//  Created by Sushant Alone on 02/08/20.
//  Copyright © 2020 Sushant Alone. All rights reserved.
//

import UIKit

class ImageVC: UIViewController {
    var fullScreenImageView: UIImageView = UIImageView(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        view.addSubview(fullScreenImageView)
        installImageView()
        // Do any additional setup after loading the view.
    }
    
    func installImageView () {
        fullScreenImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(self.view.snp.leading)
            make.trailing.equalTo(self.view.snp.trailing)
            make.bottom.equalTo(self.view.snp.bottom)
        }
        fullScreenImageView.contentMode = .scaleAspectFit
        fullScreenImageView.clipsToBounds = true
        if let image = fullScreenImageView.image{
            if image.size.width < view.frame.width &&  image.size.height < view.frame.height - 100{
                fullScreenImageView.contentMode = .center
            }
        }
        self.navigationItem.title = "Image For Pleasure!!!"
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
