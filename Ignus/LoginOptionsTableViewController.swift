//
//  LoginOptionsTableViewController.swift
//  Ignus
//
//  Created by Anant Jain on 12/21/16.
//  Copyright © 2016 Anant Jain. All rights reserved.
//

import UIKit
import LocalAuthentication

protocol LoginOptionsTableViewControllerDelegate {
    func loginOptionSetTo(_ option: String?)
}

class LoginOptionsTableViewController: UITableViewController {
    
    var delegate: LoginOptionsTableViewControllerDelegate?
    
    var currentLoginOption: String = {
        if let option = UserDefaults.standard.string(forKey: "LoginOptions") {
            return option
        }
        else {
            UserDefaults.standard.set(Constants.LoginOptions.RequirePassword, forKey: "LoginOptions")
            UserDefaults.standard.synchronize()
            
            return Constants.LoginOptions.RequirePassword
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Setting Cell", for: indexPath)

        switch (indexPath.row) {
        case 0:
            cell.textLabel?.text = "Require Password"
            if currentLoginOption == Constants.LoginOptions.RequirePassword {
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }
        case 1:
            cell.textLabel?.text = "Touch ID"
            if currentLoginOption == Constants.LoginOptions.TouchID {
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }
        case 2:
            cell.textLabel?.text = "Automatic Login"
            if currentLoginOption == Constants.LoginOptions.AutomaticLogin {
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }
        default:
            break
        }
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.gray
        cell.selectedBackgroundView = backgroundView

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            currentLoginOption = Constants.LoginOptions.RequirePassword
            
            UserDefaults.standard.set(currentLoginOption, forKey: "LoginOptions")
            UserDefaults.standard.synchronize()
            
            tableView.reloadData()
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            tableView.deselectRow(at: indexPath, animated: true)
        case 1:
            // Checks if Touch ID is available on the current device
            let context = LAContext()
            var error: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                currentLoginOption = Constants.LoginOptions.TouchID
                
                UserDefaults.standard.set(currentLoginOption, forKey: "LoginOptions")
                UserDefaults.standard.synchronize()
            }
            else {
                let errorAlert = UIAlertController(title: "Error", message: "Touch ID is not available.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                present(errorAlert, animated: true, completion: nil)
            }
            
            tableView.reloadData()
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            tableView.deselectRow(at: indexPath, animated: true)
        case 2:
            currentLoginOption = Constants.LoginOptions.AutomaticLogin
            
            UserDefaults.standard.set(currentLoginOption, forKey: "LoginOptions")
            UserDefaults.standard.synchronize()
            
            tableView.reloadData()
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            tableView.deselectRow(at: indexPath, animated: true)
        default:
            break
        }
        
        self.delegate?.loginOptionSetTo(currentLoginOption)
    }

}
