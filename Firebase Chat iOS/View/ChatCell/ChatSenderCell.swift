//
//  ChatSenderCell.swift
//  SampleCodeiOS
//
//  Created by Tops on 05/10/21.
//

import UIKit

class ChatSenderCell: UITableViewCell {

    @IBOutlet weak var lbl_date: UILabel!
    @IBOutlet weak var lbl_message:UILabel!
    @IBOutlet weak var view_bubble:UIView!
    @IBOutlet weak var img_tick:UIImageView!
    
    @IBOutlet weak var imgRightCheck:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
