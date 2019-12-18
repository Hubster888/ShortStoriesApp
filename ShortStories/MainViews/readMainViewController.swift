//
//  readMainViewController.swift
//  ShortStories
//
//  Created by Hubert Rzeminski on 09/12/2019.
//  Copyright © 2019 Hubert Rzeminski. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class readMainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    // MARK: Variable initiations and connections
    var theme = "None"
    let currentUser = Auth.auth().currentUser
    let currentUserID = Auth.auth().currentUser?.uid
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var searchBox: UITextField!
    let ref = Database.database().reference()
    var publishedStoriesArray : [Story] = [Story]()
    
    //MARK: tableView functions
    func registerTableViewCells(){
        let textFieldCell = UINib(nibName: "BookCellsTableViewCell", bundle: nil)
        self.tableView.register(textFieldCell, forCellReuseIdentifier: "BookCellsTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return publishedStoriesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCellsTableViewCell", for: indexPath) as! BookCellsTableViewCell //Cell is created using a custom class
        let currentLastItem = self.publishedStoriesArray[indexPath.row]
        cell.titleOfStory?.text = currentLastItem.title
        cell.nameOfAuthor?.text = "By " + currentLastItem.author
        cell.numOfLikes?.text = String(currentLastItem.numOfLikes)
        if(currentLastItem.liked){
            cell.likedButton?.alpha = 1
        }else{
            cell.likedButton?.alpha = 0.2
        }
        cell.likedButton.addTarget(self, action: #selector(likeStory), for: .touchUpInside)
        cell.likedButton.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! BookCellsTableViewCell
        let title = currentCell.titleOfStory.text!
        viewStory(title: title)
    }
    
    
    
    //MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        childrensTheme.addTarget(self, action: #selector(childrensPressed), for: .touchUpInside)
        adultTheme.addTarget(self, action: #selector(adultPressed), for: .touchUpInside)
        horrorTheme.addTarget(self, action: #selector(horrorPressed), for: .touchUpInside)
        loveTheme.addTarget(self, action: #selector(lovePressed), for: .touchUpInside)
        scifiTheme.addTarget(self, action: #selector(scifiPressed), for: .touchUpInside)
        comedyTheme.addTarget(self, action: #selector(comedyPressed), for: .touchUpInside)
        crimeTheme.addTarget(self, action: #selector(crimePressed), for: .touchUpInside)
        fantasyTheme.addTarget(self, action: #selector(fantasyPressed), for: .touchUpInside)
        otherTheme.addTarget(self, action: #selector(otherPressed), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backPressed), for: .touchUpInside)
        backButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        publishedStoriesArray.removeAll()
        createStoryArray()
        tableView.rowHeight = 80
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        self.registerTableViewCells()
        tableView.layer.cornerRadius = 15
        tableView.separatorStyle = .none
    }
    
    //MARK: other functions
    func viewStory( title: String){
        ref.child("stories").observeSingleEvent(of: .value, with: {
            (snapshot) in
            let value = snapshot.value as? NSDictionary
            let publishedStories = (value!["published"]) as? [[String : Any]] ?? [["storyId":0]]
            var i = -1
            for story in publishedStories {
                i += 1
                if (i > 0){
                    if (story["title"] as! String == title){
                        let storyId = story["storyId"] as! Int
                        self.ref.child("users/\(self.currentUser!.uid)/tempId").setValue(storyId)
                        self.performSegue(withIdentifier: "readPage", sender: nil)
                        break
                    }
                }
            }
        })
    }
    
    @objc func likeStory(_ sender: UIButton) {
        let indexPathRow = sender.tag
        ref.child("stories").observeSingleEvent(of: .value, with: {
            (snapshot) in
            let value = snapshot.value as? NSDictionary
            var publishedStories = (value!["published"]) as? [[String:Any]] ?? [["storyId":0]]
            publishedStories = publishedStories.sorted(by: {$1["storyId"]! as! Int > $0["storyId"]! as! Int})
            let story = publishedStories[indexPathRow + 1]
            if(story["liked"] as! Bool == false){
                self.likeStoryWhileNotLikedPublished(story: story, publishedStories: publishedStories, indexPathRow: indexPathRow)
                self.viewWillAppear(true)
            }else{
                self.likeStoryWhileLikedPublished(story: story, publishedStories: publishedStories, indexPathRow: indexPathRow)
                self.viewWillAppear(true)
            }
        })
        ref.child("users").child(currentUserID!).observeSingleEvent(of: .value, with: {
            (snapshot) in
            let value = snapshot.value as? NSDictionary
            var userStories = (value!["userStories"]) as? [[String : Any]] ?? [["storyId":0]]
            userStories = userStories.sorted(by: {$1["storyId"]! as! Int > $0["storyId"]! as! Int })
            let story = userStories[indexPathRow + 1]
            if(story["liked"] as! Bool == false){ //Check if story is already liked
                self.likeStoryWhileNotLikedUser(story: story, userStories: userStories, indexPathRow: indexPathRow)
            }else{// If liked then pressing the button makes it disliked
                self.likeStoryWhileLikedUser(story: story, userStories: userStories, indexPathRow: indexPathRow)
            }
        })
    }
    
    func likeStoryWhileNotLikedPublished(story: [String:Any], publishedStories: [[String:Any]], indexPathRow: Int){
        var publishedStories = publishedStories
        let numOfLikes = (story["numOfLikes"] as! Int) + 1
        let newStory : [String:Any] = ["title" : story["title"]!, "author" : story["author"]!,
        "numOfLikes" : numOfLikes, "liked" : true,
        "storyId" : story["storyId"]!, "published" : story["published"]!,
        "content" : story["content"]!,
        "theme" : story["theme"]!]
        publishedStories = publishedStories.sorted(by: {$1["storyId"]! as! Int > $0["storyId"]! as! Int })
        publishedStories.remove(at: indexPathRow + 1)
        publishedStories.append(newStory)
        self.ref.child("stories/published").setValue(publishedStories)
    }
    
    func likeStoryWhileLikedPublished(story: [String:Any], publishedStories: [[String:Any]], indexPathRow: Int){
        var publishedStories = publishedStories
        let numOfLikes = (story["numOfLikes"] as! Int) - 1
        let newStory : [String:Any] = ["title" : story["title"]!, "author" : story["author"]!,
        "numOfLikes" : numOfLikes, "liked" : false,
        "storyId" : story["storyId"]!, "published" : story["published"]!,
        "content" : story["content"]!,
        "theme": story["theme"]!]
        publishedStories = publishedStories.sorted(by: {$1["storyId"]! as! Int > $0["storyId"]! as! Int })
        publishedStories.remove(at: indexPathRow + 1)
        publishedStories.append(newStory)
        self.ref.child("stories/published").setValue(publishedStories)
    }
    
    func likeStoryWhileNotLikedUser(story: [String:Any], userStories: [[String:Any]], indexPathRow: Int){
        var userStories = userStories
        let numOfLikes = (story["numOfLikes"] as! Int) + 1
        let newStory : [String:Any] = ["title" : story["title"]!, "author" : story["author"]!,
        "numOfLikes" : numOfLikes, "liked" : true,
        "storyId" : story["storyId"]!, "published" : story["published"]!,
        "content" : story["content"]!]
        userStories = userStories.sorted(by: {$1["storyId"]! as! Int > $0["storyId"]! as! Int })
        userStories.remove(at: indexPathRow + 1)
        userStories.append(newStory)
        self.ref.child("users/\(self.currentUser!.uid)/userStories").setValue(userStories)
    }
    
    func likeStoryWhileLikedUser(story: [String:Any], userStories: [[String:Any]], indexPathRow: Int){
        var userStories = userStories
        let numOfLikes = (story["numOfLikes"] as! Int) - 1
        let newStory : [String:Any] = ["title" : story["title"]!, "author" : story["author"]!,
        "numOfLikes" : numOfLikes, "liked" : false,
        "storyId" : story["storyId"]!, "published" : story["published"]!,
        "content" : story["content"]!]
        userStories = userStories.sorted(by: {$1["storyId"]! as! Int > $0["storyId"]! as! Int })
        userStories.remove(at: indexPathRow + 1)
        userStories.append(newStory)
        self.ref.child("users/\(self.currentUser!.uid)/userStories").setValue(userStories)
    }
    
    @objc func backPressed(){
        publishedStoriesArray.removeAll()
        theme = "None"
        self.tableView.isHidden = true
        adultTheme.isHidden = false
        childrensTheme.isHidden = false
        horrorTheme.isHidden = false
        loveTheme.isHidden = false
        scifiTheme.isHidden = false
        comedyTheme.isHidden = false
        crimeTheme.isHidden = false
        fantasyTheme.isHidden = false
        otherTheme.isHidden = false
    }
    
    func createStoryArray(){
        ref.child("stories").observeSingleEvent(of: .value, with: {
            (snapshot) in
            let value = snapshot.value as? NSDictionary
            let publishedStories = (value?["published"] ?? "published empty") as? [[String : Any]] ?? [["storyId":0]]
            if(type(of: publishedStories) == type(of: "string")){
                return
            }else{
                for story in publishedStories{
                    if (story.count > 1){
                        if (story["theme"]! as! String == self.theme){
                            let title = story["title"]
                            let author = story["author"]
                            let numOfLikes = story["numOfLikes"]
                            let storyId = story["storyId"]
                            let liked = story["liked"]
                            let published = story["published"]
                            let content = story["content"]
                            let themeOfStory = story["theme"]
                            let book = Story(title: title as! String, author: author as! String, numOfLikes: numOfLikes as! Int, liked: liked as! Bool, id: storyId as! Int, published: published as! Bool, content: content as! String, theme: themeOfStory as! String)
                            self.makeArray(book: book)
                        }
                    }
                }
            }
        })
    }
    
    func makeArray(book: Story){
        self.publishedStoriesArray.append(book)
        self.publishedStoriesArray = self.publishedStoriesArray.sorted(by: {$0.id < $1.id })
        self.tableView.reloadData()
    }
    
    //MARK: Picking a theme and its buttons
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var childrensTheme: UIButton!
    @IBOutlet weak var adultTheme: UIButton!
    @IBOutlet weak var horrorTheme: UIButton!
    @IBOutlet weak var loveTheme: UIButton!
    @IBOutlet weak var scifiTheme: UIButton!
    @IBOutlet weak var comedyTheme: UIButton!
    @IBOutlet weak var crimeTheme: UIButton!
    @IBOutlet weak var fantasyTheme: UIButton!
    @IBOutlet weak var otherTheme: UIButton!
    
    @objc func childrensPressed(){
        pickTheme(choice: "Childrens")
    }
    
    @objc func adultPressed(){
        pickTheme(choice: "Adult")
    }
    
    @objc func horrorPressed(){
        pickTheme(choice: "Horror")
    }
    
    @objc func lovePressed(){
        pickTheme(choice: "Love")
    }
    
    @objc func scifiPressed(){
        pickTheme(choice: "Scifi")
    }
    
    @objc func comedyPressed(){
        pickTheme(choice: "Comedy")
    }
    
    @objc func crimePressed(){
        pickTheme(choice: "Crime")
    }
    
    @objc func fantasyPressed(){
        pickTheme(choice: "Fantasy")
    }
    
    @objc func otherPressed(){
        pickTheme(choice: "Other")
    }
    func pickTheme(choice: String){
        theme = choice
        adultTheme.isHidden = true
        childrensTheme.isHidden = true
        horrorTheme.isHidden = true
        loveTheme.isHidden = true
        scifiTheme.isHidden = true
        comedyTheme.isHidden = true
        crimeTheme.isHidden = true
        fantasyTheme.isHidden = true
        otherTheme.isHidden = true
        tableView.isHidden = false
        backButton.isHidden = false
        viewWillAppear(true)
    }
}
