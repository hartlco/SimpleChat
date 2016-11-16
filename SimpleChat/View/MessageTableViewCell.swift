//
//  MessageTableViewCell.swift
//  SimpleChat
//
//  Created by mhaddl on 16/11/2016.
//  Copyright © 2016 Martin Hartl. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    var ownMessage = false
    
    var username = "" {
        didSet {
            ownUsernameLabel.text = ownMessage ? username : ""
            usernameLabel.text = ownMessage ? "" : username
        }
    }
    
    var message = "" {
        didSet {
            ownMessageLabel.text = ownMessage ? message : ""
            messageLabel.text = ownMessage ? "" : message
        }
    }
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var ownUsernameLabel: UILabel!
    @IBOutlet weak var ownMessageLabel: UILabel!
    
}
