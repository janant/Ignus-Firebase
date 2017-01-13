//
//  MessagesViewController.swift
//  Ignus
//
//  Created by Anant Jain on 12/22/16.
//  Copyright © 2016 Anant Jain. All rights reserved.
//

import UIKit
import Firebase

class MessagesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
        refreshControl.addTarget(self, action: #selector(MessagesViewController.reloadData), for: .valueChanged)
        refreshControl.tintColor = UIColor.white
        messagesTable.addSubview(refreshControl)
        
//        print(FIRServerValue.timestamp())
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
        return cell
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Do nothing for now
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
