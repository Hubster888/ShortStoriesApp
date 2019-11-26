//
//  LogInView.swift
//  ShortStories
//
//  Created by Hubert Rzeminski on 25/11/2019.
//  Copyright © 2019 Hubert Rzeminski. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import GoogleSignIn

class LogInView: UIViewController, GIDSignInDelegate{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        guard let auth = user.authentication else {return}
        let credentials = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        Auth.auth().signIn(with: credentials) {
            (authResult, error) in
            if let error = error {
                print(error.localizedDescription)
            }else{
                print("Log in successful")
                self.performSegue(withIdentifier: "HomeViewSegue", sender: self)
            }
        }
        
    }
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBAction func logInWithGoogle(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    @IBAction func logInButton(_ sender: Any) {
        // The login details are checked and the user is loged in
        Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!){(user, error)
            in
            if(error == nil){
                self.performSegue(withIdentifier: "HomeViewSegue", sender: self)
            }else{
                let alertController = UIAlertController(title: "Email or Password is incorrect!", message: "Please re-enter", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }

    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
    }
}
