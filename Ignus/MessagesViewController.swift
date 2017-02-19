//
//  MessagesViewController.swift
//  Ignus
//
//  Created by Anant Jain on 12/22/16.
//  Copyright © 2016 Anant Jain. All rights reserved.
//

import UIKit
import Firebase

class MessagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MessageViewControllerDelegate, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var messagesTable: UITableView!
    @IBOutlet weak var noMessagesStackView: UIStackView!
    @IBOutlet weak var loadingMessagesActivityIndicator: UIActivityIndicatorView!
    
    var messages = [[String: Any]]()
    var senders = [[String: String]]()
    
    var unreadMessages = 0
    let refreshControl = UIRefreshControl()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Gets data if there are no messages and not already trying to get data
        if messages.count == 0 && !loadingMessagesActivityIndicator.isAnimating {
            // Shows the user that messages are loading
            self.loadingMessagesActivityIndicator.startAnimating()
            self.loadingMessagesActivityIndicator.alpha = 1.0
            self.noMessagesStackView.alpha = 0.0
            self.messagesTable.alpha = 0.0
            
            // Gets messages from IgnusBackend
            IgnusBackend.getMessages(with: { (messagesData) in
                self.messages = messagesData
                
                // If there are no messages, display this to the user
                if self.messages.count == 0 {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.loadingMessagesActivityIndicator.alpha = 0.0
                        self.noMessagesStackView.alpha = 1.0
                    }, completion: { (completed) in
                        self.loadingMessagesActivityIndicator.stopAnimating()
                    })
                }
                else { // There are messages, displays messages in the table
                    self.messagesTable.reloadData()
                    self.processMessagesData()
                    
                    UIView.animate(withDuration: 0.25, animations: {
                        self.loadingMessagesActivityIndicator.alpha = 0.0
                        self.messagesTable.alpha = 1.0
                    }, completion: { (completed) in
                        self.loadingMessagesActivityIndicator.stopAnimating()
                        self.messagesTable.isUserInteractionEnabled = true
                    })
                }
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Deselects selected index
        if let selectedIndex = messagesTable.indexPathForSelectedRow {
            messagesTable.deselectRow(at: selectedIndex, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Sets up the table
        messagesTable.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .dark))
        messagesTable.backgroundView = nil
        messagesTable.backgroundColor = UIColor.clear
        refreshControl.addTarget(self, action: #selector(MessagesViewController.reloadData), for: .valueChanged)
        refreshControl.tintColor = UIColor.white
        messagesTable.addSubview(refreshControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func reloadData() {
        
    }
    
    func processMessagesData() {
        // Do nothing for now
        // TODO: get the user data for sender of each message. Get unread count.
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Message Cell", for: indexPath)
        
        let messageData = messages[indexPath.row]
        
        // Gets views needed for setting up the table cell
        guard
            let profileImageView = cell.viewWithTag(1) as? UIImageView,
            let nameLabel = cell.viewWithTag(2) as? UILabel,
            let messageLabel = cell.viewWithTag(3) as? UILabel,
            let unreadIndicator = cell.viewWithTag(4),
            let dateLabel = cell.viewWithTag(5) as? UILabel,
        
            let senderUsername = messageData["sender"]
        else {
            return cell
        }
        
        // Sets initial data to blank, since cells get reused
        nameLabel.text = ""
        messageLabel.text = ""
        unreadIndicator.isHidden = true
        dateLabel.text = ""
        profileImageView.image = #imageLiteral(resourceName: "Not Loaded Profile")
        
        // Gets name info for this sender
        let usersDatabaseReference = FIRDatabase.database().reference().child("users/\(senderUsername)")
        usersDatabaseReference.observeSingleEvent(of: .value, with: { (snapshot) in
            guard
                let senderData = snapshot.value as? [String: String],
                let firstName = senderData["firstName"],
                let lastName = senderData["lastName"]
            else {
                return
            }
            
            UIView.transition(with: nameLabel, duration: 0.2, options: .transitionCrossDissolve, animations: {
                nameLabel.text = "\(firstName) \(lastName)"
            }, completion: nil)
        })
        
        // Gets profile image data
        let profileRef = FIRStorage.storage().reference().child("User_Pictures/\(senderUsername)/profile.jpg")
        profileRef.data(withMaxSize: INT64_MAX, completion: { (data, error) in
            if error == nil && data != nil {
                UIView.transition(with: profileImageView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    profileImageView.image = UIImage(data: data!)
                }, completion: nil)
            }
        })
        
        // Sets message text
        messageLabel.text = messageData["message"] as? String
        
        // Shows/hides unread indicator
        if let messageUnread = messageData["unread"] as? Bool {
            unreadIndicator.isHidden = !messageUnread
        }
        
        // Sets timestamp
        if let timeSent = messageData["timestamp"] as? Double {
            let messageDate = Date(timeIntervalSince1970: timeSent / 1000)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = (Calendar.current.isDateInToday(messageDate)) ? "h:mm a" : "MM/dd/yy"
            dateLabel.text = dateFormatter.string(from: messageDate)
        }
        
        cell.backgroundColor = UIColor.clear
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.gray
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Do nothing for now
    }
    
    // MARK: - MessageViewController delegate methods
    
    func canceledNewMessage(messageVC: MessageViewController) {
        messageVC.dismiss(animated: true, completion: nil)
    }
    
    func canceledViewMessage(messageVC: MessageViewController) {
        messageVC.dismiss(animated: true, completion: nil)
    }
    
    func sentNewMessage(messageVC: MessageViewController) {
        messageVC.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Transitioning delegate methods
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented is MessageViewController {
            return nil
        }
        return nil
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed is MessageViewController {
            return nil
        }
        return nil
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        if presented is MessageViewController {
            return nil
        }
        return nil
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "Show Message" {
            if let navVC = segue.destination as? UINavigationController {
                if let messageVC = navVC.topViewController as? MessageViewController {
                    messageVC.delegate = self
                }
            }
        }
    }
    

}
