//
//  ChatReceiverCell.swift
//  SampleCodeiOS
//
//  Created by Tops on 05/10/21.
//

import UIKit

class ChatReceiverCell: UITableViewCell {

    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var viewBubble: UIView!

    @IBOutlet weak var imgRightCheck: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var consUserNameHeight: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        viewBubble.roundCorners([.topRight, .bottomLeft, .bottomRight], radius: 5)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
