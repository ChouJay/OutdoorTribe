//
//  TabBarController.swift
//  OutdoorTribe
//
//  Created by Jay Chou on 2022/6/16.
//

import UIKit

class TabBarController: UITabBarController {

    var childVc: PostViewController?
    let plusButton = UIButton()
    
    @objc func tapPlus() {
        print("test")
        childVc?.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        present(childVc ?? PostViewController(), animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.layer.cornerRadius = 10
//        childVc = storyboard?.instantiateViewController(withIdentifier: "PostViewController") as? PostViewController
//        setUpPlusButtonUI()
//        self.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    func setUpPlusButtonUI() {
        plusButton.layer.cornerRadius = 25
        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy, scale: .large)
        plusButton.tintColor = .brown
        plusButton.setPreferredSymbolConfiguration(imageConfig, forImageIn: .normal)
        plusButton.addTarget(self, action: #selector(tapPlus), for: .touchUpInside)
        view.addSubview(plusButton)
        plusButton.backgroundColor = .systemGray6
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.centerYAnchor.constraint(equalTo: self.tabBar.centerYAnchor, constant: -40).isActive = true
        plusButton.centerXAnchor.constraint(equalTo: self.tabBar.centerXAnchor).isActive = true
        plusButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        plusButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
    }
}

extension TabBarController: UITabBarControllerDelegate {
//    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        print(item.tag)
//        if item.tag == 1 {
//            plusButton.isHidden = true
//        } else {
//            plusButton.isHidden = false
//        }
//    }
}
