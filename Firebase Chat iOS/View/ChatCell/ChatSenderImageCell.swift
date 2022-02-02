//
//  ChatSenderImageCell.swift
//  Firebase Chat iOS
//
//  Created by Tops on 13/10/21.
//

import UIKit

class ChatSenderImageCell: UITableViewCell {

    @IBOutlet weak var lbl_date: UILabel!
    @IBOutlet weak var img_media:UIImageView!
    @IBOutlet weak var btn_play:UIButton!
    @IBOutlet weak var img_tick:UIImageView!
    @IBOutlet weak var viewBGColor:UIView!
    @IBOutlet weak var view_circel_progress:CircularProgressView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
