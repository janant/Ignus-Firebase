//
//  MessageViewController.swift
//  Ignus
//
//  Created by Anant Jain on 2/13/17.
//  Copyright © 2017 Anant Jain. All rights reserved.
//

import UIKit
import Firebase

protocol MessageViewControllerDelegate: class {
    func canceledNewMessage(messageVC: MessageViewController)
    func canceledViewMessage(messageVC: MessageViewController)
    func sentNewMessage(messageVC: MessageViewController)
}

class MessageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, ChooseFriendViewControllerDelegate {
    
    // Table in which the message is displayed
    @IBOutlet weak var messageTable: UITableView!
    
    // The message text view
    var messageTextView: UITextView!
    var recipientLabel: UILabel!
    
    var messageToDisplay: String?
    
    var defaultRecipient: String?
    var selectedRecipient: String?
    
    weak var delegate: MessageViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Deselects the currently selected table view cell
        if let selectedIndexPath = messageTable.indexPathForSelectedRow {
            messageTable.deselectRow(at: selectedIndexPath, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // If viewing a message someone sent you
        if messageToDisplay != nil {
            self.title = "Message"
            
            // Sets right bar button item to reply button
            let replyButton = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(MessageViewController.replyToMessage))
            self.navigationItem.rightBarButtonItem = replyButton
        }
        //
        else {
            self.title = "New Message"
            
            // Sets right bar button item to send button
            let sendButton = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(MessageViewController.sendMessage))
            sendButton.isEnabled = false
            self.navigationItem.rightBarButtonItem = sendButton
        }
        
        // Adds blur separator effect
        messageTable.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .dark))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendMessage() {
        self.title = "Sending..."
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        guard
            let currentUser = FIRAuth.auth()?.currentUser,
            let currentUserUsername = currentUser.displayName,
            let recipientUsername = selectedRecipient
        else {
            return
        }
        let recipientMessagesDatabase = FIRDatabase.database().reference().child("messages/\(recipientUsername)")
        
        var newMessageData = [String: Any]()
        newMessageData["sender"] = currentUserUsername
        newMessageData["recipient"] = recipientUsername
        newMessageData["message"] = messageTextView.text
        newMessageData["unread"] = true
        newMessageData["timestamp"] = FIRServerValue.timestamp()
        
        recipientMessagesDatabase.observeSingleEvent(of: .value, with: { (snapshot) in
            var recipientMessages = (snapshot.value as? [[String: Any]]) ?? [[String: Any]]()
            recipientMessages.insert(newMessageData, at: 0)
            
            recipientMessagesDatabase.setValue(recipientMessages, withCompletionBlock: { (error, databaseReference) in
                if error == nil {
                    self.messageTextView.resignFirstResponder()
                    self.delegate?.sentNewMessage(messageVC: self)
                }
            })
        })
        
    }
    
    func replyToMessage() {
        self.title = "Reply"
        self.messageTextView.text = ""
        self.messageTextView.becomeFirstResponder()
        self.selectedRecipient = defaultRecipient
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Select Recipient Cell", for: indexPath)
            
            recipientLabel = cell.detailTextLabel
            
            // Makes cell unselectable if the sender has been predetermined
            if defaultRecipient != nil {
                cell.detailTextLabel?.text = defaultRecipient!
                cell.isUserInteractionEnabled = false
                cell.accessoryType = .none
            }
            
            // Configures selection highlight color
            let selectedView = UIView()
            selectedView.backgroundColor = UIColor.gray
            cell.selectedBackgroundView = selectedView
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Write Message Cell", for: indexPath)
            
            messageTextView = cell.viewWithTag(1) as? UITextView
            messageTextView.becomeFirstResponder()
            messageTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            messageTextView.delegate = self
            
            return cell
        }
        
    }

    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 44
        }
        else {
            return 157
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            performSegue(withIdentifier: "Choose Friend", sender: nil)
        }
    }
    
    // MARK: - Text view delegate methods
    
    func textViewDidChange(_ textView: UITextView) {
        // Enables and disables send button depending on conditions
        if let sendButton = self.navigationItem.rightBarButtonItem
        {
            let whitespaceClearedText = textView.text.replacingOccurrences(of: " ", with: "")
            sendButton.isEnabled = whitespaceClearedText.characters.count != 0 && selectedRecipient != nil
        }
    }
    
    // MARK: - ChooseFriendViewController delegate methods
    
    func choseFriend(_ friend: String) {
        self.selectedRecipient = friend
        recipientLabel.text = friend
        self.textViewDidChange(messageTextView)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "Choose Friend" {
            if let chooseFriendVC = segue.destination as? ChooseFriendViewController {
                chooseFriendVC.delegate = self
            }
        }
    }
    
    @IBAction func returnToMessage(_ segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func dismissMessage(_ sender: Any) {
        self.messageTextView.resignFirstResponder()
        
        if messageToDisplay != nil {
            self.delegate?.canceledViewMessage(messageVC: self)
        }
        else {
            self.delegate?.canceledNewMessage(messageVC: self)
        }
    }

}
