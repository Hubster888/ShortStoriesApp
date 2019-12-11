//
//  WriteViewController.swift
//  ShortStories
//
//  Created by Hubert Rzeminski on 02/12/2019.
//  Copyright © 2019 Hubert Rzeminski. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class WriteViewController: UIViewController{
    
    //MARK: Variables
    let reference = Database.database().reference()
    let currentUsersID = Auth.auth().currentUser?.uid
    let currentUser = Auth.auth().currentUser
    var storyAuthor = "unknowns"
    var usedStoryIDs: [Int] = [Int]()
    var currentStoryID = 0
    var userStories: [[String:Any]] = [[String:Any]]()
    
    //MARK: Storyboard connections
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var storyField: UITextView!
    
    @IBAction func backButton(_ sender: Any) {
        self.reference.child("users/\(self.currentUser!.uid)/tempId").setValue(0)
        performSegue(withIdentifier: "saved", sender: nil)
    }
    
    @IBAction func publishButton(_ sender: Any) {
    }
    
    @IBAction func saveButton(_ sender: Any) { //Read values under "users/userID"
        reference.child("users").child(currentUsersID!).observeSingleEvent(of: .value, with: {
            (snapshot1) in
            let value = snapshot1.value as? NSDictionary
            let temporaryStoryID = (value?["tempId"] as? Int) ?? 0
            if(temporaryStoryID == 0){ // when tempID is 0 it means it is a new story
                self.saveNewStroy()
            }else{
                self.updateStory(temporaryStoryID: temporaryStoryID) // when tempID is not 0 it means the story is being edited
            }
        })
            }
    
    //MARK: View delegates
    override func viewDidLoad(){
        super.viewDidLoad()
        self.reference.child("users").child(currentUsersID!).observeSingleEvent(of: .value, with: {
            (snapshot) in
            let value = snapshot.value as? NSDictionary
            let temporaryStoryID = (value?["tempId"] as? Int) ?? 0
            if (temporaryStoryID != 0){
                self.setValuesOnPage(id: temporaryStoryID) // Function called when story being edited
            }
            })
    }
    
    //MARK: Created functions
    private func setValuesOnPage(id: Int){ // Function called to edit the story
        reference.child("users").child(currentUsersID!).observeSingleEvent(of: .value, with: {
            (snapshot1) in
            let value = snapshot1.value as? NSDictionary
            let temporaryStoryID = (value?["tempId"] as? Int) ?? 0
            self.reference.child("users").child(self.currentUsersID!).observeSingleEvent(of: .value, with: {
                (snapshot) in
                let value = snapshot.value as? NSDictionary
                let userStories = (value?["userStories"] as? [[String:Any]]) ?? [["Nope":"Broke"]]
                var i = -1
                for story in userStories {
                    i += 1
                    if(i > 0){
                        if(story["storyId"] as! Int == temporaryStoryID){
                            let title = story["title"] as! String
                            let content = story["content"]
                            print(title)
                            self.titleField.text = title
                            self.storyField.text = content as? String
                            break
                        }
                    }
                }
            })
        })
    }
    
    private func saveNewStroy(){ // Function called once all values for the story have been entered and it is a new story
        self.reference.child("users").child(self.currentUsersID!).observeSingleEvent(of: .value, with: {
            (snapshot1) in
            let value = snapshot1.value as? NSDictionary
            self.userStories = (value!["userStories"]) as? [[String : Any]] ?? [["storyId":0]]
            self.storyAuthor = value!["name"] as? String ?? "Unknown"
            
            self.reference.child("stories").observeSingleEvent(of: .value, with: {
                (snapshot) in
                let value = snapshot.value as? NSDictionary
                self.usedStoryIDs = (value?["usedId"] as? Array<Int>) ?? [000]
                
                repeat{
                    self.currentStoryID = Int.random(in: 1 ..< 9999999)
                }while(self.usedStoryIDs.contains(self.currentStoryID))
                
                let newStory: [String:Any] = ["title": self.titleField.text!, "author": self.storyAuthor,
                "numOfLikes" : 0, "liked" : false,
                "storyId": self.currentStoryID, "published": false,
                "content": self.storyField.text!]
                self.userStories.append(newStory)
                self.usedStoryIDs.append(self.currentStoryID)
                self.reference.child("users/\(self.currentUser!.uid)/userStories").setValue(self.userStories)
                self.reference.child("stories/usedId").setValue(self.usedStoryIDs)
                self.reference.child("users/\(self.currentUser!.uid)/tempId").setValue(0)
            })
        })
        performSegue(withIdentifier: "saved", sender: nil)
    }
    
    private func updateStory(temporaryStoryID: Int){ // Function called when save button pressed and it is a pre-existing story
        self.reference.child("users").child(self.currentUsersID!).observeSingleEvent(of: .value, with: {
            (snapshot) in
            let value = snapshot.value as? NSDictionary
            var userStories = (value?["userStories"] as? Array<[String:Any]>) ?? [["Nope":"Broke"]]
            var i = -1
            for story in userStories{
                i += 1
                if(i > 0){
                    if(story["storyId"] as! Int == temporaryStoryID){
                        
                        let newStory: [String:Any] = ["title": self.titleField.text!, "author": story["author"]!,
                        "numOfLikes": story["numOfLikes"]!, "liked": story["liked"]!,
                        "storyId": story["storyId"]!, "published": story["published"]!,
                        "content": self.storyField.text!]
                        for index in 1...userStories.count - 1{
                            if(NSDictionary(dictionary: userStories[index]).isEqual(to: story)){
                                userStories.remove(at: index)
                                userStories.append(newStory)
                            }
                        }
                        self.reference.child("users/\(self.currentUser!.uid)/userStories").setValue(userStories)
                        self.reference.child("users/\(self.currentUser!.uid)/tempId").setValue(0)
                    }
                }
            }
        })
        performSegue(withIdentifier: "saved", sender: nil)
    }
}


