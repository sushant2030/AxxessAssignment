//
//  TextVC.swift
//  AxxessAssignment
//
//  Created by Sushant Alone on 02/08/20.
//  Copyright © 2020 Sushant Alone. All rights reserved.
//

import UIKit

class TextVC: UIViewController {
    
    var textView: UITextView = UITextView(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(textView)
        installTextView()
        
        // Do any additional setup after loading the view.
    }
    
    func installTextView()  {
        textView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(self.view.snp.leading)
            make.trailing.equalTo(self.view.snp.trailing)
            make.bottom.equalTo(self.view.snp.bottom)
        }
        textView.textAlignment = .center
        view.backgroundColor = .white
        textView.contentOffset = .zero
        textView.isEditable = false
        if Helper.isDeviceIPad() {
            textView.font = UIFont.systemFont(ofSize: 20)
        }
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
