//
//  MessagesViewController.swift
//  Ignus
//
//  Created by Anant Jain on 12/22/16.
//  Copyright © 2016 Anant Jain. All rights reserved.
//

import UIKit
import Firebase

class MessagesViewController: UIViewController {
    
    @IBOutlet weak var messagesTable: UITableView!
    @IBOutlet weak var noMessagesStackView: UIStackView!
    @IBOutlet weak var loadingMessagesActivityIndicator: UIActivityIndicatorView!
    
    var unreadMessages = 0
    
    let refreshControl = UIRefreshControl()
    
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
        refreshControl.addTarget(self, action: #selector(MessagesViewController.reloadData), for: .valueChanged)
        refreshControl.tintColor = UIColor.white
        messagesTable.addSubview(refreshControl)
        
        guard
            let currentUser = FIRAuth.auth()?.currentUser,
            let username = currentUser.displayName
        else {
            return
        }
        
        let databaseRef = FIRDatabase.database().reference().child("messages").child(username)
        databaseRef.updateChildValues(["4": ["timeSent": 50, "message": "git gud"]])
        
        databaseRef.child("messages").child(username).queryOrdered(byChild: "timeSent").observe(.value, with: { (snapshot) in
            print(snapshot.value ?? "rekt")
            print("divider")
        })
        
        print(FIRServerValue.timestamp())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func reloadData() {
        
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
