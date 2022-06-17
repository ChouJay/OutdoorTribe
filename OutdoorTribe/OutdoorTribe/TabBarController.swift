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
        childVc = storyboard?.instantiateViewController(withIdentifier: "PostViewController") as? PostViewController
        setUpPlusButtonUI()
        // Do any additional setup after loading the view.
    }
    

    func setUpPlusButtonUI() {
        plusButton.addTarget(self, action: #selector(tapPlus), for: .touchUpInside)
        view.addSubview(plusButton)
        plusButton.backgroundColor = .black
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.centerYAnchor.constraint(equalTo: self.tabBar.centerYAnchor, constant: -50).isActive = true
        plusButton.centerXAnchor.constraint(equalTo: self.tabBar.centerXAnchor).isActive = true
    }
}
