//
//  MyAccountViewController.swift
//  Ignus
//
//  Created by Anant Jain on 12/20/16.
//  Copyright © 2016 Anant Jain. All rights reserved.
//

import UIKit
import Firebase

class MyAccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, LoginOptionsTableViewControllerDelegate, UIViewControllerTransitioningDelegate, ProfileOptionsViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var myProfileView: UIView!
    @IBOutlet weak var myProfileInfoView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var coverView: UIImageView!
    
    @IBOutlet weak var profileOptionsButton: UIButton!
    
    @IBOutlet weak var settingsTable: UITableView!
    
    var loginOptionsDetailLabel: UILabel?
    
    var profilePickerVC: UIImagePickerController?
    var coverPickerVC: UIImagePickerController?
    
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
            let username = IgnusBackend.currentUserUsername
        else {
            return
        }
        
        // Gets data from IgnusBackend class
        IgnusBackend.getCurrentUserInfo { (currentUserInfo) in
            guard
                let firstName = currentUserInfo["firstName"],
                let lastName  = currentUserInfo["lastName"]
                else {
                    return
            }
            
            // Loads profile picture
            IgnusBackend.getCurrentUserProfileImage(with: { (error, image) in
                if error == nil {
                    UIView.transition(with: self.profileView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        self.profileView.image = image
                    }, completion: nil)
                }
            })
            // Loads cover picture
            IgnusBackend.getCurrentUserCoverPhoto(with: { (error, image) in
                if error == nil {
                    UIView.transition(with: self.coverView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        self.coverView.image = image
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
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(MyAccountViewController.refreshProfile(_:)), name: NSNotification.Name(rawValue: Constants.NotificationNames.ReloadProfileImages), object: nil)
    }
    
    func refreshProfile(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo as? [String: UIImage],
            let profileImage = userInfo[Constants.UserInfoKeys.Profile],
            let coverImage = userInfo[Constants.UserInfoKeys.Cover]
        else {
            return
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            self.profileView.image = profileImage
            self.coverView.image = coverImage
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
            
            var cellFrame = cell.frame
            cellFrame = CGRect(x: cellFrame.origin.x, y: cellFrame.origin.y, width: cellFrame.width - 200, height: cellFrame.height)
            cell.frame = cellFrame
            
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
                
                IgnusBackend.resetState()
                
                // Logs out
                try? FIRAuth.auth()?.signOut()
                
                UserDefaults.standard.set(Constants.LoginOptions.None, forKey: "LoginOptions")
                UserDefaults.standard.synchronize()
                
                self.dismiss(animated: true, completion: nil)
                
            }))
            logoutConfirmation.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
                self.settingsTable.deselectRow(at: indexPath, animated: true)
            }))
            
            // Sets popover information for iPad
            let logoutCellFrame = tableView.rectForRow(at: indexPath)
            let convertedLogoutCellFrame = self.view.convert(logoutCellFrame, from: tableView)
            
            logoutConfirmation.popoverPresentationController?.sourceRect = convertedLogoutCellFrame
            logoutConfirmation.popoverPresentationController?.sourceView = self.view
            
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
                return "None"
            }
        }()
    }
    
    // MARK: - Profile options view controller delegate methods
    
    func changeProfilePicture() {
        // Create an image picker to change profile picture
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.allowsEditing = true
        imagePickerVC.delegate = self
        imagePickerVC.sourceType = .photoLibrary // Default
        
        // Creates an action sheet to choose from either photo library or camera
        let imagePickerSourceSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        imagePickerSourceSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerVC.sourceType = .camera
                
                UINavigationBar.appearance().titleTextAttributes = nil
                UISegmentedControl.appearance().setTitleTextAttributes(nil, for: UIControlState())
                UIBarButtonItem.appearance().setTitleTextAttributes(nil, for: UIControlState())
                
                self.profilePickerVC = imagePickerVC
                
                self.present(imagePickerVC, animated: true, completion: nil)
            }
            else {
                let errorAlert = UIAlertController(title: "Error", message: "Ignus does not have access to the camera. You may need to enable access in Settings.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }))
        imagePickerSourceSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                imagePickerVC.sourceType = .photoLibrary
                
                UINavigationBar.appearance().titleTextAttributes = nil
                UISegmentedControl.appearance().setTitleTextAttributes(nil, for: UIControlState())
                UIBarButtonItem.appearance().setTitleTextAttributes(nil, for: UIControlState())
                
                self.profilePickerVC = imagePickerVC
                
                self.present(imagePickerVC, animated: true, completion: nil)
            }
            else {
                let errorAlert = UIAlertController(title: "Error", message: "Ignus does not have access to your photos library. You may need to enable access in Settings.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }))
        imagePickerSourceSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        imagePickerSourceSheet.popoverPresentationController?.sourceView = profileOptionsButton
        
        present(imagePickerSourceSheet, animated: true, completion: nil)
    }
    
    func changeCoverPicture() {
        // Create an image picker to change cover picture
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.allowsEditing = true
        imagePickerVC.delegate = self
        imagePickerVC.sourceType = .photoLibrary // Default
        
        // Creates an action sheet to choose from either photo library or camera
        let imagePickerSourceSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        imagePickerSourceSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerVC.sourceType = .camera
                
                UINavigationBar.appearance().titleTextAttributes = nil
                UISegmentedControl.appearance().setTitleTextAttributes(nil, for: UIControlState())
                UIBarButtonItem.appearance().setTitleTextAttributes(nil, for: UIControlState())
                
                self.coverPickerVC = imagePickerVC
                
                self.present(imagePickerVC, animated: true, completion: nil)
            }
            else {
                let errorAlert = UIAlertController(title: "Error", message: "Ignus does not have access to the camera. You may need to enable access in Settings.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }))
        imagePickerSourceSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                imagePickerVC.sourceType = .photoLibrary
                
                UINavigationBar.appearance().titleTextAttributes = nil
                UISegmentedControl.appearance().setTitleTextAttributes(nil, for: UIControlState())
                UIBarButtonItem.appearance().setTitleTextAttributes(nil, for: UIControlState())
                
                UIBarButtonItem.appearance().setTitleTextAttributes(nil, for: UIControlState())
                UINavigationBar.appearance().titleTextAttributes = nil
                
                self.coverPickerVC = imagePickerVC
                
                self.present(imagePickerVC, animated: true, completion: nil)
            }
            else {
                let errorAlert = UIAlertController(title: "Error", message: "Ignus does not have access to your photos library. You may need to enable access in Settings.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }))
        imagePickerSourceSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        imagePickerSourceSheet.popoverPresentationController?.sourceView = profileOptionsButton
        
        present(imagePickerSourceSheet, animated: true, completion: nil)
    }
    
    // MARK: - Image picker controller delegate methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Gotham-Medium", size: 18)!]
        UISegmentedControl.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: 234/255, green: 51/255, blue: 56/255, alpha: 1.0), NSFontAttributeName: UIFont(name: "Gotham-Book", size: 14)!], for: UIControlState())
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: 234/255, green: 51/255, blue: 56/255, alpha: 1.0), NSFontAttributeName: UIFont(name: "Gotham-Medium", size: 17)!], for: UIControlState())
        
        picker.dismiss(animated: true, completion: nil)
        
        guard
            let username = IgnusBackend.currentUserUsername,
            let editedImage = (editingInfo[UIImagePickerControllerEditedImage] as? UIImage ?? editingInfo[UIImagePickerControllerOriginalImage] as? UIImage),
            let imageData = UIImageJPEGRepresentation(editedImage, 0.7)
        else {
                return
        }
        
        if picker === profilePickerVC {
            // Creates a loading indicator
            let loadingAlert = UIAlertController(title: "Changing profile picture...", message: "\n\n", preferredStyle: .alert)
            let loadingIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            loadingIndicatorView.color = UIColor.gray
            loadingIndicatorView.startAnimating()
            loadingIndicatorView.center = CGPoint(x: 135, y: 65.5)
            loadingAlert.view.addSubview(loadingIndicatorView)
            present(loadingAlert, animated: true, completion: nil)
            
            // Uploads new profile photo to Firebase
            let storageRef = FIRStorage.storage().reference()
            let profileRef = storageRef.child("User_Pictures/\(username)/profile.jpg")
            profileRef.put(imageData, metadata: nil, completion: { (metadata, error) in
                if error == nil {
                    loadingAlert.dismiss(animated: true, completion: nil)
                    
                    // Sets up user info for notification, which updates profile/cover images
                    var userInfo = [String: UIImage]()
                    userInfo[Constants.UserInfoKeys.Profile] = image
                    userInfo[Constants.UserInfoKeys.Cover] = self.coverView.image
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationNames.ReloadProfileImages), object: nil, userInfo: userInfo)
                }
            })
        }
        else if picker == coverPickerVC {
            let loadingAlert = UIAlertController(title: "Changing cover photo...", message: "\n\n", preferredStyle: .alert)
            let loadingIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            loadingIndicatorView.color = UIColor.gray
            loadingIndicatorView.startAnimating()
            loadingIndicatorView.center = CGPoint(x: 135, y: 65.5)
            loadingAlert.view.addSubview(loadingIndicatorView)
            present(loadingAlert, animated: true, completion: nil)
            
            // Uploads new cover photo to Firebase
            let storageRef = FIRStorage.storage().reference()
            let profileRef = storageRef.child("User_Pictures/\(username)/cover.jpg")
            profileRef.put(imageData, metadata: nil, completion: { (metadata, error) in
                if error == nil {
                    loadingAlert.dismiss(animated: true, completion: nil)
                    
                    // Sets up user info for notification, which updates profile/cover images
                    var userInfo = [String: UIImage]()
                    userInfo[Constants.UserInfoKeys.Profile] = self.profileView.image
                    userInfo[Constants.UserInfoKeys.Cover] = image
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationNames.ReloadProfileImages), object: nil, userInfo: userInfo)
                }
            })
        }
        
        profilePickerVC = nil
        coverPickerVC = nil
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Gotham-Medium", size: 18)!]
        UISegmentedControl.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: 234/255, green: 51/255, blue: 56/255, alpha: 1.0), NSFontAttributeName: UIFont(name: "Gotham-Book", size: 14)!], for: UIControlState())
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: 234/255, green: 51/255, blue: 56/255, alpha: 1.0), NSFontAttributeName: UIFont(name: "Gotham-Medium", size: 17)!], for: UIControlState())
        
        picker.dismiss(animated: true, completion: nil)
        
        profilePickerVC = nil
        coverPickerVC = nil
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented is ProfileOptionsViewController {
            let buttonCenter = self.view.convert(profileOptionsButton.center, from: myProfileInfoView)
            return ProfileOptionsAnimation(presenting: true, initialPoint: buttonCenter)
        }
        return nil
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed is ProfileOptionsViewController {
            let buttonCenter = self.view.convert(profileOptionsButton.center, from: myProfileInfoView)
            return ProfileOptionsAnimation(presenting: false, initialPoint: buttonCenter)
        }
        return nil
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        if presented is ProfileOptionsViewController {
            return ProfileOptionsPresentation(presentedViewController: presented, presenting: presenting)
        }
        return nil
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
        else if segue.identifier == "Show Profile Options" {
            let profileOptionsVC = segue.destination as! ProfileOptionsViewController
            profileOptionsVC.profileType = Constants.ProfileTypes.CurrentUser
            profileOptionsVC.delegate = self
            profileOptionsVC.modalPresentationStyle = .custom
            profileOptionsVC.transitioningDelegate = self
        }
    }
 

}
