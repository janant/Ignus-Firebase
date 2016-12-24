//
//  MessagesViewController.swift
//  Ignus
//
//  Created by Anant Jain on 12/22/16.
//  Copyright © 2016 Anant Jain. All rights reserved.
//

import UIKit

class MessagesViewController: UIViewController {
    
    @IBOutlet weak var messagesTable: UITableView!
    @IBOutlet weak var noMessagesStackView: UIStackView!
    @IBOutlet weak var loadingMessagesActivityIndicator: UIActivityIndicatorView!

    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
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
