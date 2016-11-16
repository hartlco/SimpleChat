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
    static let MessageCellidentifier = "MessageCellidentifier"
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UINib(nibName: "OwnMessageTableViewCell", bundle: nil), forCellReuseIdentifier: ChatViewController.OwnMessageCellIdentifier)
            tableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: ChatViewController.MessageCellidentifier)
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 44.0
        }
    }
    
    @IBOutlet weak var messageTextField: UITextField! {
        didSet {
            messageTextField.delegate = self
        }
    }
    
    
    fileprivate let username: String
    fileprivate let messageStore: MessageStore
    
    init(username: String) {
        self.username = username
        self.messageStore = MessageStore()
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
        return messageStore.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messageStore.messages[indexPath.row]
        
        guard let ownMessageCell = tableView.dequeueReusableCell(withIdentifier: ChatViewController.OwnMessageCellIdentifier, for: indexPath) as? OwnMessageTableViewCell else { return UITableViewCell() }
        
        ownMessageCell.usernameLabel.text = message.username
        ownMessageCell.messageLabel.text = message.message
        return ownMessageCell
    }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let messageText = textField.text else { return false }
        
        let message = Message(username: username, message: messageText, date: Date(), ownMessage: true)
        messageStore.send(message: message)
        return true
    }
}
