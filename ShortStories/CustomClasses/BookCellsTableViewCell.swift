//
//  BookCellsTableViewCell.swift
//  ShortStories
//
//  Created by Hubert Rzeminski on 26/11/2019.
//  Copyright © 2019 Hubert Rzeminski. All rights reserved.
//

import UIKit

class BookCellsTableViewCell: UITableViewCell {
    @IBOutlet weak var titleOfStory: UILabel!
    @IBOutlet weak var nameOfAuthor: UILabel!
    @IBOutlet weak var numOfLikes: UILabel!
    @IBOutlet weak var likedButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
