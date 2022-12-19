//
//  ChatSenderImageCell.swift
//  Firebase Chat iOS
//
//  Created by Tops on 13/10/21.
//

import UIKit

class ChatSenderImageCell: UITableViewCell {

    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imgMedia: UIImageView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var imgTick: UIImageView!
    @IBOutlet weak var viewBGColor: UIView!
    @IBOutlet weak var viewCircelProgress: CircularProgressView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
