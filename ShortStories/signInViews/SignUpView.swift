//
//  SignUpView.swift
//  ShortStories
//
//  Created by Hubert Rzeminski on 25/11/2019.
//  Copyright © 2019 Hubert Rzeminski. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import GoogleSignIn

class SignUpView: UIViewController, GIDSignInDelegate{
    var ref = Database.database().reference()
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
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
                let user = Auth.auth().currentUser
                let email = user?.email
                self.writeUserData(email: email!)
                self.performSegue(withIdentifier: "HomeViewSegue", sender: self)
            }
        }
    }
    
    @IBAction func signUpWithGoogle(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        if (passwordField.text != confirmPasswordField.text){ // Here the passwords are checked
            let alertController = UIAlertController(title: "Password incorect", message: "Please re-type password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil) // Error box shows
        }else{// Otherwise create an account
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!){(user, error)
                in
                if(error == nil){
                    self.writeUserData(email: self.emailField.text!)
                    self.performSegue(withIdentifier: "HomeViewSegue", sender: self)
                }else{
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func writeUserData(email : String){
        let user = Auth.auth().currentUser
        self.ref.child("users/\(user!.uid)/email").setValue(email)
        self.ref.child("users/\(user!.uid)/firstTime").setValue(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
    }
}
