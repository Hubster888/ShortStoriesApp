//
//  PreviewViewController.swift
//  ShortStories
//
//  Created by Hubert Rzeminski on 12/12/2019.
//  Copyright © 2019 Hubert Rzeminski. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class PreviewViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    var theme = "None"
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        themeList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return themeList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        changeThemeValue(row: row)
    }
    
    func changeThemeValue(row: Int){
        switch row {
        case 0:
            self.theme = "Childrens"
            break
        case 1:
            self.theme = "Adult"
            break
        case 2:
            self.theme = "Horror"
            break
        case 3:
            self.theme = "Love"
            break
        case 4:
            self.theme = "Sci-fi"
            break
        case 5:
            self.theme = "Comedy"
            break
        case 6:
            self.theme = "Crime"
            break
        case 7:
            self.theme = "Fantasy"
            break
        case 8:
            self.theme = "Other"
            break
        default:
            self.theme = "None"
            break
        }
    }
    
    let themeList : [String] = ["Childrens","Adult","Horror","Love","Sci-fi","Comedy","Crime", "Fantasy", "Other"]
    let ref = Database.database().reference()
    let currentUser = Auth.auth().currentUser
    var publishedStories: [[String:Any]] = [[String:Any]]()
    var newStory: [String:Any] = [:]
    @IBOutlet weak var themePicker: UIPickerView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var storyBox: UITextView!
    @IBAction func confirmButton(_ sender: Any) {
        ref.child("users").child(currentUser!.uid).observeSingleEvent(of: .value, with: {
            (snapshot) in
            let value = snapshot.value as? NSDictionary
            let temporaryStoryID = (value?["tempId"] as? Int) ?? 0
            self.ref.child("users").child(self.currentUser!.uid).observeSingleEvent(of: .value, with: {
                (snapshot) in
                let value = snapshot.value as? NSDictionary
                var userStories = (value?["userStories"] as? [[String:Any]]) ?? [["Nope":"Broke"]]
                var i = -1
                for story in userStories {
                    i += 1
                    if(i > 0){
                        if(story["storyId"] as! Int == temporaryStoryID){
                            let title = story["title"] as! String
                            let content = story["content"]!
                            let author = story["author"]!
                            let numOfLikes = story["numOfLikes"]!
                            let liked = story["liked"]!
                            let storyID = story["storyId"]!
                            self.newStory = ["title": title, "author": author,
                                "numOfLikes" : numOfLikes, "liked" : liked,
                                "storyId": storyID, "published": true,
                                "content": content, "theme": self.theme]
                            for index in 1...userStories.count - 1{
                                if(NSDictionary(dictionary: userStories[index]).isEqual(to: story)){
                                    userStories.remove(at: index)
                                    userStories.append(self.newStory)
                                }
                            }
                            break
                        }
                    }
                }
                self.ref.child("stories").observeSingleEvent(of: .value, with: {
                    (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    self.publishedStories = (value!["published"]) as? [[String : Any]] ?? [["storyId":0]]
                    self.publishedStories.append(self.newStory)
                    print(self.publishedStories)
                    self.ref.child("stories/published").setValue(self.publishedStories)
                })

                self.ref.child("users/\(self.currentUser!.uid)/userStories").setValue(userStories)
            })
        })
        performSegue(withIdentifier: "backHome", sender: nil)
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.themePicker.delegate = self
        self.themePicker.dataSource = self
        ref.child("users").child(currentUser!.uid).observeSingleEvent(of: .value, with: {
            (snapshot) in
            let value = snapshot.value as? NSDictionary
            let temporaryStoryID = (value?["tempId"] as? Int) ?? 0
            self.ref.child("users").child(self.currentUser!.uid).observeSingleEvent(of: .value, with: {
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
                            self.titleLabel.text = title
                            self.storyBox.text = content as? String
                            break
                        }
                    }
                }
                
            })
        })
    }
}
