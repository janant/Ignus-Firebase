//
//  MessageViewController.swift
//  Ignus
//
//  Created by Anant Jain on 2/13/17.
//  Copyright © 2017 Anant Jain. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Table in which the message is displayed
    @IBOutlet weak var messageTable: UITableView!
    
    // The message text view
    var messageTextView: UITextView!
    
    var messageToDisplay: String?
    var defaultSender: String?
    
    var selectedSender: String?
    
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
        
    }
    
    func replyToMessage() {
        self.title = "Reply"
        self.messageTextView.text = ""
        self.messageTextView.becomeFirstResponder()
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
            
            // Makes cell unselectable if the sender has been predetermined
            if defaultSender != nil {
                cell.detailTextLabel?.text = defaultSender!
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
            // Sets text inset
            messageTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            
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
    
    @IBAction func dismissMessage(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
