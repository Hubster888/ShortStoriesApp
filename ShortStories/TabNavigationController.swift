//
//  TabNavigationController.swift
//  ShortStories
//
//  Created by Hubert Rzeminski on 25/11/2019.
//  Copyright © 2019 Hubert Rzeminski. All rights reserved.
//
import UIKit
import Foundation

class TabNavigationController: UINavigationController{
    override func viewDidLoad() {
        super.viewDidLoad()
        var freshLaunch = true
        if (freshLaunch == true){
            freshLaunch = false
            self.tabBarController?.selectedIndex = 1
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        var freshLaunch = true
        if (freshLaunch == true){
            freshLaunch = false
            self.tabBarController?.selectedIndex = 1
        }
    }
}

