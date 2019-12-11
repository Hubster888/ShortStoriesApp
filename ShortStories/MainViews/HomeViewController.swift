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
    var name = "empty"
    var ref = Database.database().reference()
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
        guard let userID = Auth.auth().currentUser?.uid else { return  }
        ref.child("users").child(userID).observeSingleEvent(of: .value, with: {
            (snapshot) in
            let value = snapshot.value as? NSDictionary
            let firstLogin = value?["firstTime"] as? Bool ?? false
            if(firstLogin){
                self.ref.child("users/\(userID)/firstTime").setValue(false)
                self.name = self.askForName()
                self.ref.child("users/\(userID)/name").setValue(self.name)
                print(self.name)
            }
        })
    }
    
    func askForName() -> String{
        let alert = UIAlertController(title: "Add Name", message: "Enter your full name please:", preferredStyle: .alert)
        alert.addTextField{
            (textField) in
            textField.text = "Enter name"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {[weak alert] (_) in
            guard let userID = Auth.auth().currentUser?.uid else { return  }
            let textField = alert?.textFields![0]
            let name = textField!.text ?? "No value"
            self.ref.child("users/\(userID)/name").setValue(name)
        }))
        self.present(alert, animated: true, completion: nil)
        return name
    }
}
