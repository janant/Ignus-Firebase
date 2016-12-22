//
//  MyAccountViewController.swift
//  Ignus
//
//  Created by Anant Jain on 12/20/16.
//  Copyright © 2016 Anant Jain. All rights reserved.
//

import UIKit
import Firebase

class MyAccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, LoginOptionsTableViewControllerDelegate {
    
    @IBOutlet weak var myProfileView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var coverView: UIImageView!
    
    @IBOutlet weak var friendOptionsButton: UIButton!
    
    @IBOutlet weak var settingsTable: UITableView!
    
    var loginOptionsDetailLabel: UILabel?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedIndex = settingsTable.indexPathForSelectedRow {
            settingsTable.deselectRow(at: selectedIndex, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Sets initial blank text labels
        nameLabel.text = ""
        usernameLabel.text = ""
        
        // Makes sure username is gathered
        guard
            let currentUser = FIRAuth.auth()?.currentUser,
            let username = currentUser.displayName
        else {
            return
        }
        
        // Getes user info dictionary from Firebase
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("users").child(currentUser.displayName!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            // Ensures necessary user info is gathered
            guard
                let userInfo  = snapshot.value as? [String: String],
                let firstName = userInfo["firstName"],
                let lastName  = userInfo["lastName"]
            else {
                return
            }
            
            // Gets profile and cover photo references from Firebase
            let storageRef = FIRStorage.storage().reference()
            let profileRef = storageRef.child("User_Pictures/\(username)/profile.png")
            let coverRef = storageRef.child("User_Pictures/\(username)/cover.png")
            
            // Loads profile picture
            profileRef.data(withMaxSize: INT64_MAX, completion: { (data, error) in
                if error == nil && data != nil {
                    UIView.transition(with: self.profileView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        self.profileView.image = UIImage(data: data!)
                    }, completion: nil)
                }
            })
            // Loads cover picture
            coverRef.data(withMaxSize: INT64_MAX, completion: { (data, error) in
                if error == nil && data != nil {
                    UIView.transition(with: self.coverView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        self.coverView.image = UIImage(data: data!)
                    }, completion: nil)
                }
            })
            
            // Fades in new data
            UIView.transition(with: self.nameLabel, duration: 0.2, options: .transitionCrossDissolve, animations: { 
                self.nameLabel.text = "\(firstName) \(lastName)"
            }, completion: nil)
            UIView.transition(with: self.usernameLabel, duration: 0.2, options: .transitionCrossDissolve, animations: {
                self.usernameLabel.text = username
            }, completion: nil)
        })
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "Setting Detail Cell", for: indexPath)
            
            cell.textLabel?.text = "Login Options"
            
            self.loginOptionsDetailLabel = cell.detailTextLabel
            loginOptionSetTo(UserDefaults.standard.string(forKey: "LoginOptions"))
            
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
                
                UserDefaults.standard.set(Constants.LoginOptions.RequirePassword, forKey: "LoginOptions")
                UserDefaults.standard.synchronize()
                
                self.dismiss(animated: true, completion: nil)
            }))
            logoutConfirmation.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
                self.settingsTable.deselectRow(at: indexPath, animated: true)
            }))
            present(logoutConfirmation, animated: true, completion: nil)
        }
    }
    
    func loginOptionSetTo(_ option: String?) {
        loginOptionsDetailLabel?.text = {
            guard let loginOption = option else {
                return "Require Password"
            }
            
            switch loginOption {
            case Constants.LoginOptions.RequirePassword:
                return "Require Password"
            case Constants.LoginOptions.TouchID:
                return "Touch ID"
            case Constants.LoginOptions.AutomaticLogin:
                return "Automatic Login"
            default:
                return "Require Password"
            }
        }()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "Show Login Options" {
            if let loginOptionsTVC = segue.destination as? LoginOptionsTableViewController {
                loginOptionsTVC.delegate = self
            }
        }
    }
 

}
