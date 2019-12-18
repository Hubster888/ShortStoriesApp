//
//  ReadPage.swift
//  
//
//  Created by Hubert Rzeminski on 18/12/2019.
//

import Foundation
import UIKit
import Firebase

class ReadPage:UIViewController {
    
    let ref = Database.database().reference()
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTextField: UITextView!
    @IBAction func backButton(_ sender: Any) {
        performSegue(withIdentifier: "backHome", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentUser = Auth.auth().currentUser
        ref.child("users").child(currentUser!.uid).observeSingleEvent(of: .value, with: {
            (snapshot) in
            let value = snapshot.value as? NSDictionary
            let temporaryStoryID = (value?["tempId"] as? Int) ?? 0
            self.ref.child("stories").observeSingleEvent(of: .value, with: {
                (snapshot) in
                let value = snapshot.value as? NSDictionary
                let publishedStories = (value?["published"] as? [[String:Any]]) ?? [["Nope":"Broke"]]
                var i = -1
                for story in publishedStories {
                    i += 1
                    if(i > 0){
                        if(story["storyId"] as! Int == temporaryStoryID){
                            let title = story["title"] as! String
                            let content = story["content"]
                            self.titleLabel.text = title
                            self.contentTextField.text = content as? String
                            break
                        }
                    }
                }
            })
        })
        
        ref.child("stories").observeSingleEvent(of: .value, with: {
            (snapshot) in
            let value = snapshot.value as? NSDictionary
            let temporaryStoryID = (value?["tempId"] as? Int) ?? 0
            let publishedStories = (value?["published"] as? [[String:Any]]) ?? [["Nope":"Broke"]]
            var i = -1
            for story in publishedStories {
                i += 1
                if(i > 0){
                    if(story["storyId"] as! Int == temporaryStoryID){
                        let title = story["title"] as! String
                        let content = story["content"]
                        self.titleLabel.text = title
                        self.contentTextField.text = content as? String
                        break
                    }
                }
            }
        })
    }
}
