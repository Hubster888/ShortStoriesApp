//
//  HomeViewController.swift
//  ShortStories
//
//  Created by Hubert Rzeminski on 25/11/2019.
//  Copyright © 2019 Hubert Rzeminski. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class HomeViewController: UIViewController{
    @IBAction func logOutButton(_ sender: Any) {
        do{
            try Auth.auth().signOut()
        }catch (let signOutError as NSError){
            print("Error signing out: %@", signOutError)
        }
        self.performSegue(withIdentifier: "LogOut", sender: self)
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
    }
}
