//
//  ViewController.swift
//  ShortStories
//
//  Created by Hubert Rzeminski on 25/11/2019.
//  Copyright © 2019 Hubert Rzeminski. All rights reserved.
//

import UIKit
import Firebase

class WelcomePageController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(Auth.auth().currentUser != nil){
            self.performSegue(withIdentifier: "HomeViewSegue", sender: nil)
        }
    }



}

