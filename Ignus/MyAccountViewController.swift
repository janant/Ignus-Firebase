//
//  MyAccountViewController.swift
//  Ignus
//
//  Created by Anant Jain on 12/20/16.
//  Copyright © 2016 Anant Jain. All rights reserved.
//

import UIKit
import Firebase

class MyAccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var myProfileView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var coverView: UIImageView!
    
    @IBOutlet weak var friendOptionsButton: UIButton!
    
    @IBOutlet weak var settingsTable: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedIndex = settingsTable.indexPathForSelectedRow {
            settingsTable.deselectRow(at: selectedIndex, animated: true)
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
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Setting Cell", for: indexPath)
            
            cell.textLabel?.text = "Login Options"
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.gray
            cell.selectedBackgroundView = backgroundView
            
            return cell
        }
        else if (indexPath as NSIndexPath).section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Setting Cell", for: indexPath)
            
            cell.textLabel?.text = "Acknowledgements"
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.gray
            cell.selectedBackgroundView = backgroundView
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Log Out Cell", for: indexPath)
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.gray
            cell.selectedBackgroundView = backgroundView
            
            return cell
        }
    }
    
    // MARK: - Table view delegate methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
            performSegue(withIdentifier: "Show Login Options", sender: nil)
        }
        else if (indexPath as NSIndexPath).section == 1 {
            performSegue(withIdentifier: "Show Acknowledgements", sender: nil)
        }
        else if (indexPath as NSIndexPath).section == 2 {
            // Creates and presents logout action sheet
            let logoutConfirmation = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            logoutConfirmation.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (action) -> Void in
                // Logs out
                try? FIRAuth.auth()?.signOut()
                
                UserDefaults.standard.set(false, forKey: "AutomaticLoginEnabled")
                UserDefaults.standard.synchronize()
                
                self.dismiss(animated: true, completion: nil)
            }))
            logoutConfirmation.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
                self.settingsTable.deselectRow(at: indexPath, animated: true)
            }))
            present(logoutConfirmation, animated: true, completion: nil)
        }
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
