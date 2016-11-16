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
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    fileprivate let username: String
    fileprivate let messageStore: MessageStore
    
    init(username: String) {
        self.username = username
        self.messageStore = MessageStore()
        super.init(nibName: String(describing: ChatViewController.self), bundle: nil)
        self.messageStore.messageInsertBlock = insertRow
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func insertRow() {
        let messages = self.messageStore.messages
        let latestIndexPath = IndexPath(row: messages.count - 1, section: 0)
        self.tableView.insertRows(at: [latestIndexPath], with: .automatic)
    }
    
    // MARK: - Keyboard
    
    internal func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.bottomConstraint?.constant = 16.0
            } else {
                self.bottomConstraint?.constant = ((endFrame?.size.height) ?? 0) + 16.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
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
        if message.ownMessage {
            guard let ownMessageCell = tableView.dequeueReusableCell(withIdentifier: ChatViewController.OwnMessageCellIdentifier, for: indexPath) as? OwnMessageTableViewCell else { return UITableViewCell() }
            
            ownMessageCell.usernameLabel.text = message.username
            ownMessageCell.messageLabel.text = message.message
            return ownMessageCell
        } else {
            guard let messageCell = tableView.dequeueReusableCell(withIdentifier: ChatViewController.MessageCellidentifier, for: indexPath) as? MessageTableViewCell else { return UITableViewCell() }
            
            messageCell.usernameLabel.text = message.username
            messageCell.messageLabel.text = message.message
            return messageCell
        }
    }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let messageText = textField.text else { return false }
        
        let message = Message(username: username, message: messageText, date: Date(), ownMessage: true)
        messageStore.send(message: message)
        textField.text = ""
        textField.resignFirstResponder()
        return true
    }
}
