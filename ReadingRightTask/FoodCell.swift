//
//  FoodCell.swift
//  ReadingRightTask
//
//  Created by Chandra Hasan on 04/08/21.
//

import UIKit

class FoodCell: UITableViewCell {

    @IBOutlet var thumbnailImg: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var areaLabel: UILabel!
    @IBOutlet var myView: UIView!
    @IBOutlet var favBtn: UIButton!
    @IBOutlet var descriptionLbl: UILabel!
    @IBOutlet var ingrediants: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        myView.layer.shadowOffset = CGSize(width: myView.frame.size.width,
//                                           height: myView.frame.size.height)
//        myView.layer.shadowRadius = 5
//        myView.layer.shadowOpacity = 0.3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
