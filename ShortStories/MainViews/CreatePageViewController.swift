//
//  CreatePageViewController.swift
//  ShortStories
//
//  Created by Hubert Rzeminski on 26/11/2019.
//  Copyright © 2019 Hubert Rzeminski. All rights reserved.
//

import Foundation
import Firebase
import UIKit

class CreatePageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    //MARK: Variables
    var storiesArray : [Story] = [Story]()
    let reference = Database.database().reference()
    let currentUser = Auth.auth().currentUser
    let currentUserID = Auth.auth().currentUser?.uid
    
    //MARK: Storyboard connections
    @IBOutlet weak var tableView: UITableView!
    @IBAction func addButton(_ sender: Any) {
        loadAddPopUp()
    }
    
    //MARK: Tableview delegates
    func registerTableViewCells(){
        let textFieldCell = UINib(nibName: "BookCellsTableViewCell", bundle: nil)
        self.tableView.register(textFieldCell, forCellReuseIdentifier: "BookCellsTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storiesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCellsTableViewCell", for: indexPath) as! BookCellsTableViewCell //Cell is created using a custom class
        let currentLastItem = storiesArray[indexPath.row]
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
        editStory(title: title)
    }
    
    //MARK: View delegates
    override func viewWillAppear(_ animated: Bool) { //Sets up the view/ tableview
        super.viewDidLoad()
        storiesArray.removeAll()
        createStoryArray()
        self.tableView.reloadData()
        tableView.rowHeight = 80
        self.tableView.delegate = self
        self.registerTableViewCells()
        tableView.layer.cornerRadius = 15
        tableView.separatorStyle = .none
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
    }
    
    //MARK: Button functions
    @objc func likeStory(_ sender: UIButton) {
        let indexPathRow = sender.tag
        //print(indexPathRow)// Change story liked not depending on placing in the table
        reference.child("users").child(currentUserID!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            var userStories = (value!["userStories"]) as? [[String : Any]] ?? [["storyId":0]]
            userStories = userStories.sorted(by: {$1["storyId"]! as! Int > $0["storyId"]! as! Int })
            let story = userStories[indexPathRow + 1]
            if(story["liked"] as! Bool == false){ //Check if story is already liked
                self.likeStoryWhileNotLiked(story: story, userStories: userStories, indexPathRow: indexPathRow)
                self.viewWillAppear(true)
            }else{// If liked then pressing the button makes it disliked
                self.likeStoryWhileLiked(story: story, userStories: userStories, indexPathRow: indexPathRow)
                self.viewWillAppear(true)
            }
        })
    }
    
    //MARK: Created functions
    func likeStoryWhileNotLiked(story: [String:Any], userStories: [[String:Any]], indexPathRow: Int){
        var userStories = userStories
        let numOfLikes = (story["numOfLikes"] as! Int) + 1
        let newStory : [String:Any] = ["title" : story["title"]!, "author" : story["author"]!,
        "numOfLikes" : numOfLikes, "liked" : true,
        "storyId" : story["storyId"]!, "published" : story["published"]!,
        "content" : story["content"]!]
        userStories = userStories.sorted(by: {$1["storyId"]! as! Int > $0["storyId"]! as! Int })
        userStories.remove(at: indexPathRow + 1)
        userStories.append(newStory)
        self.reference.child("users/\(self.currentUser!.uid)/userStories").setValue(userStories)
        self.tableView.reloadData()
    }
    
    func likeStoryWhileLiked(story: [String:Any], userStories: [[String:Any]], indexPathRow: Int){
        var userStories = userStories
        let numOfLikes = (story["numOfLikes"] as! Int) - 1
        let newStory : [String:Any] = ["title" : story["title"]!, "author" : story["author"]!,
        "numOfLikes" : numOfLikes, "liked" : false,
        "storyId" : story["storyId"]!, "published" : story["published"]!,
        "content" : story["content"]!]
        userStories = userStories.sorted(by: {$1["storyId"]! as! Int > $0["storyId"]! as! Int })
        userStories.remove(at: indexPathRow + 1)
        userStories.append(newStory)
        self.reference.child("users/\(self.currentUser!.uid)/userStories").setValue(userStories)
        self.tableView.reloadData()
    }
    
    func createStoryArray(){
        let ref = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let userStories = (value!["userStories"]) as? [[String : Any]] ?? [["storyId":0]]
            for story in userStories{
                if (story.count > 1){
                    let title = story["title"]
                    let author = story["author"]
                    let numOfLikes = story["numOfLikes"]
                    let storyId = story["storyId"]
                    let liked = story["liked"]
                    let published = story["published"]
                    let content = story["content"]
                    let book = Story(title: title as! String, author: author as! String, numOfLikes: numOfLikes as! Int, liked: liked as! Bool, id: storyId as! Int, published: published as! Bool, content: content as! String, theme: "None")
                    self.makeArray(book: book)
                }
            }
        })
            }
    
    private func loadAddPopUp(){
        let alert = UIAlertController(title: "Upload or Write", message: "Would you like to upload a word document or write the story from scratch?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Upload", style: .default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Write", style: .default, handler: {
            action in
            self.performSegue(withIdentifier: "WritePage", sender: nil)
        }))
        self.present(alert, animated: true)
    }
    
    func makeArray(book: Story){
        storiesArray.append(book)
        self.storiesArray = self.storiesArray.sorted(by: {$0.id < $1.id })
        self.tableView.reloadData()
    }
    
    func editStory( title: String){
        reference.child("users").child(currentUserID!).observeSingleEvent(of: .value, with: {
            (snapshot) in
            let value = snapshot.value as? NSDictionary
            let userStories = (value!["userStories"]) as? [[String : Any]] ?? [["storyId":0]]
            var i = -1
            for story in userStories {
                i += 1
                if (i > 0){
                    if (story["title"] as! String == title){
                        let storyId = story["storyId"] as! Int
                        self.reference.child("users/\(self.currentUser!.uid)/tempId").setValue(storyId)
                        self.performSegue(withIdentifier: "WritePage", sender: nil)
                        break
                    }
                }
            }
        })
    }
}
