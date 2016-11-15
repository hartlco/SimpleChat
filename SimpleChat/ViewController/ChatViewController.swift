//
//  ChatViewController.swift
//  SimpleChat
//
//  Created by mhaddl on 15/11/2016.
//  Copyright © 2016 Martin Hartl. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    
    static let OwnMessageCellIdentifier = "OwnMessageCellIdentifier"
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UINib(nibName: "OwnMessageTableViewCell", bundle: nil), forCellReuseIdentifier: ChatViewController.OwnMessageCellIdentifier)
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 44.0
        }
    }
    private let username: String
    
    init(username: String) {
        self.username = username
        super.init(nibName: String(describing: ChatViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ownMessageCell = tableView.dequeueReusableCell(withIdentifier: ChatViewController.OwnMessageCellIdentifier, for: indexPath)
        
        return ownMessageCell
    }
}
