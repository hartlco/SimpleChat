//
//  ChatViewController.swift
//  SimpleChat
//
//  Created by mhaddl on 15/11/2016.
//  Copyright © 2016 Martin Hartl. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    private let username: String
    
    init(username: String) {
        self.username = username
        super.init(nibName: String(describing: ChatViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
