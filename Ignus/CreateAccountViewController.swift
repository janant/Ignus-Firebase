//
//  CreateAccountViewController.swift
//  Ignus
//
//  Created by Anant Jain on 10/29/16.
//  Copyright © 2016 Anant Jain. All rights reserved.
//

import UIKit
import Firebase

protocol CreateAccountViewControllerDelegate {
    func createdAccount(withUsername username: String, andPassword password: String)
}

class CreateAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var creatingAccountView: UIVisualEffectView!
    @IBOutlet weak var backgroundBlurView: UIVisualEffectView!
    
    @IBOutlet weak var firstNameTextFieldBox: UIView!
    @IBOutlet weak var lastNameTextFieldBox: UIView!
    @IBOutlet weak var emailTextFieldBox: UIView!
    @IBOutlet weak var usernameTextFieldBox: UIView!
    @IBOutlet weak var passwordTextFieldBox: UIView!
    @IBOutlet weak var confirmPasswordTextFieldBox: UIView!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var creatingAccountIndicatorView: UIActivityIndicatorView!
    
    var delegate: CreateAccountViewControllerDelegate?
    
    var toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 300)
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        toolbar.barStyle = .black
        toolbar.tintColor = UIColor.white
        toolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(CreateAccountViewController.resignTextBoxFirstResponder))]
        
        firstNameTextField.inputAccessoryView = toolbar
        lastNameTextField.inputAccessoryView = toolbar
        emailTextField.inputAccessoryView = toolbar
        usernameTextField.inputAccessoryView = toolbar
        passwordTextField.inputAccessoryView = toolbar
        confirmPasswordTextField.inputAccessoryView = toolbar
        
        NotificationCenter.default.addObserver(self, selector: #selector(CreateAccountViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CreateAccountViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.view.clipsToBounds = true
    }
    
    func keyboardWillShow(_ sender: Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            if let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue?.height {
                self.scrollView.contentInset.bottom = keyboardHeight
            }
        }
    }
    
    func keyboardWillHide(_ sender: Notification) {
        self.scrollView.contentInset.bottom = 0
        self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    func resignTextBoxFirstResponder() {
        if firstNameTextField.isFirstResponder {
            firstNameTextField.resignFirstResponder()
        }
        else if lastNameTextField.isFirstResponder {
            lastNameTextField.resignFirstResponder()
        }
        else if emailTextField.isFirstResponder {
            emailTextField.resignFirstResponder()
        }
        else if usernameTextField.isFirstResponder {
            usernameTextField.resignFirstResponder()
        }
        else if passwordTextField.isFirstResponder {
            passwordTextField.resignFirstResponder()
        }
        else if confirmPasswordTextField.isFirstResponder {
            confirmPasswordTextField.resignFirstResponder()
        }
    }
    
    @IBAction func selectFirstNameTextField(_ sender: AnyObject) {
        firstNameTextField.becomeFirstResponder()
    }
    
    @IBAction func selectLastNameTextField(_ sender: AnyObject) {
        lastNameTextField.becomeFirstResponder()
    }
    
    @IBAction func selectEmailTextField(_ sender: AnyObject) {
        emailTextField.becomeFirstResponder()
    }
    
    @IBAction func selectUsernameTextField(_ sender: AnyObject) {
        usernameTextFieldBox.becomeFirstResponder()
    }
    
    @IBAction func selectPasswordTextField(_ sender: AnyObject) {
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func selectConfirmPasswordTextField(_ sender: AnyObject) {
        confirmPasswordTextField.becomeFirstResponder()
    }
    
    @IBAction func cancelAccountCreation(_ sender: AnyObject) {
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        var offset = textField.superview!.frame.origin
        offset.x = 0
        offset.y -= 60
        
        scrollView.setContentOffset(offset, animated: true)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstNameTextField:
            lastNameTextField.becomeFirstResponder()
        case lastNameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            usernameTextField.becomeFirstResponder()
        case usernameTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        case confirmPasswordTextField:
            confirmPasswordTextField.resignFirstResponder()
        default:
            break
        }
        return true
    }
    
    @IBAction func signUp(_ sender: AnyObject) {
        // Sets up loading views
        creatingAccountIndicatorView.startAnimating()
        self.scrollView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.scrollView.alpha = 0.0
        }, completion: { (completed) -> Void in
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.creatingAccountView.alpha = 1.0
            })
        })
        
        // Possible errors with sign up information
        var alert: UIAlertController?
        
        if firstNameTextField.text!.replacingOccurrences(of: " ", with: "").characters.count == 0 {
            alert = UIAlertController(title: "Error", message: "Please enter a valid first name.", preferredStyle: .alert)
        }
        else if lastNameTextField.text!.replacingOccurrences(of: " ", with: "").characters.count == 0 {
            alert = UIAlertController(title: "Error", message: "Please enter a valid last name.", preferredStyle: .alert)
        }
        else if emailTextField.text!.replacingOccurrences(of: " ", with: "").characters.count == 0 {
            alert = UIAlertController(title: "Error", message: "Please enter a valid email address.", preferredStyle: .alert)
        }
        else if usernameTextField.text!.replacingOccurrences(of: " ", with: "").characters.count == 0 {
            alert = UIAlertController(title: "Error", message: "Please enter a valid username.", preferredStyle: .alert)
        }
        else if passwordTextField.text!.characters.count == 0 {
            alert = UIAlertController(title: "Error", message: "Please enter a valid password.", preferredStyle: .alert)
        }
        else if confirmPasswordTextField.text!.characters.count == 0 {
            alert = UIAlertController(title: "Error", message: "Please confirm your password.", preferredStyle: .alert)
        }
        else if (passwordTextField.text != confirmPasswordTextField.text) {
            alert = UIAlertController(title: "Error", message: "The password and the confirmation password are not the same.", preferredStyle: .alert)
        }
        
        // If there is an error, display the error and get rid of loading views
        if let errorAlert = alert {
            errorAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
            present(errorAlert, animated: true, completion: nil)
            
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.creatingAccountView.alpha = 0.0
            }, completion: { (completed) -> Void in
                self.creatingAccountIndicatorView.startAnimating();
                self.scrollView.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
                    self.scrollView.alpha = 1.0
                })
            })
        }
        else {
            // Sign up information
            guard
                let email = emailTextField.text?.replacingOccurrences(of: " ", with: ""),
                let password = passwordTextField.text?.replacingOccurrences(of: " ", with: ""),
                let firstName = firstNameTextField.text?.replacingOccurrences(of: " ", with: ""),
                let lastName = lastNameTextField.text?.replacingOccurrences(of: " ", with: ""),
                let username = usernameTextField.text?.replacingOccurrences(of: " ", with: "")
            else {
                return
            }
            
            // Attempts to create the user with email and password
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    // Gets default profile and cover photos as Data objects
                    guard
                        let profileData = UIImagePNGRepresentation(#imageLiteral(resourceName: "Default Profile Photo")),
                        let coverData = UIImagePNGRepresentation(#imageLiteral(resourceName: "Default Cover Photo"))
                    else {
                        return
                    }
                    
                    // Sets the new user's profile and cover photo to the defaults
                    let storageRef = FIRStorage.storage().reference()
                    let profileRef = storageRef.child("User_Pictures/\(username)/profile.png")
                    let coverRef = storageRef.child("User_Pictures/\(username)/cover.png")
                    profileRef.put(profileData, metadata: nil, completion: { (profileMetadata, profileError) in
                        if profileError == nil {
                            coverRef.put(coverData, metadata: nil, completion: { (coverMetadata, coverError) in
                                if coverError == nil {
                                    guard
                                        let profileURL = profileMetadata?.downloadURL(),
                                        let coverURL = coverMetadata?.downloadURL()
                                    else {
                                        return
                                    }
                                    
                                    // Creates an additional Firebase object with additional user information
                                    let newUserInfo = [
                                            "firstName": firstName,
                                            "lastName": lastName,
                                            "username": username,
                                            "email": email,
                                            "profile": profileURL.absoluteString,
                                            "cover": coverURL.absoluteString
                                    ]
                                    let ref = FIRDatabase.database().reference()
                                    ref.child("users").child(username).setValue(newUserInfo)
                                    
                                    // Sets user display name to username
                                    let changeRequest = user!.profileChangeRequest()
                                    changeRequest.displayName = username
                                    changeRequest.commitChanges(completion: { (error) in
                                        if error == nil {
                                            self.dismiss(animated: true, completion: { () -> Void in
                                                self.delegate?.createdAccount(withUsername: username, andPassword: password)
                                            })
                                        }
                                    })
                                }
                            })
                        }
                    })
                }
                else {
                    let errorAlert = UIAlertController(title: "lel rekt", message: "some error occurred", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                }
            })
            
//            let newUser = PFUser()
//            newUser.username = usernameTextField.text!.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
//            newUser.password = passwordTextField.text!.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
//            newUser.email = emailTextField.text!.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
//            
//            let firstName = firstNameTextField.text!.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
//            let lastName = lastNameTextField.text!.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
            
//            newUser["FirstName"] = firstName
//            newUser["LastName"] = lastName
//            newUser["FullName"] = firstName + " " + lastName
            
//            let profileFile = PFFile(name: "Profile.png", data: UIImagePNGRepresentation(UIImage(named: "DefaultProfile.png")!))
//            let coverFile = PFFile(name: "Cover.png", data: UIImagePNGRepresentation(UIImage(named: "DefaultCover.png")!))
            
//            profileFile.saveInBackground({ (completed: Bool, error: NSError!) -> Void in
//                if error == nil {
//                    newUser["Profile"] = profileFile
//                    
//                    coverFile.saveInBackground({ (completed: Bool, error: NSError!) -> Void in
//                        if error == nil {
//                            newUser["Cover"] = coverFile
//                            
//                            newUser.signUpInBackground({ (succeeded: Bool, error: NSError!) -> Void in
//                                if error == nil {
//                                    self.dismiss(animated: true, completion: { () -> Void in
//                                        let friendsObject = PFObject(className: "Friends")
//                                        friendsObject["User"] = newUser.username
//                                        friendsObject["Friends"] = [String]()
//                                        friendsObject["Sent"] = [String]()
//                                        friendsObject["Received"] = [String]()
//                                        friendsObject.saveInBackground()
//                                        
//                                        self.delegate?.createdAccountWithUsername(self.usernameTextField.text!.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil), password: self.passwordTextField.text!.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil))
//                                    })
//                                }
//                                else {
//                                    println(error.code)
//                                    var errorMessage = error.localizedDescription
//                                    if error.code == 125 {
//                                        errorMessage = "Invalid email address."
//                                    }
//                                    else if error.code == 202 {
//                                        errorMessage = "The username is already in use. Please choose a different one."
//                                    }
//                                    else if error.code == 203 {
//                                        errorMessage = "The email address is already being used by a different account. Please choose a different one."
//                                    }
//                                    let errorAlert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
//                                    errorAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
//                                    self.present(errorAlert, animated: true, completion: nil)
//                                    
//                                    UIView.animate(withDuration: 0.2, animations: { () -> Void in
//                                        self.creatingAccountView.alpha = 0.0
//                                    }, completion: { (completed) -> Void in
//                                        self.creatingAccountIndicatorView.startAnimating();
//                                        self.scrollView.isUserInteractionEnabled = true
//                                        UIView.animate(withDuration: 0.2, animations: { () -> Void in
//                                            self.scrollView.alpha = 1.0
//                                        })
//                                    })
//                                }
//                            })
//                        }
//                        else {
//                            let errorAlert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
//                            errorAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
//                            self.present(errorAlert, animated: true, completion: nil)
//                            
//                            UIView.animate(withDuration: 0.2, animations: { () -> Void in
//                                self.creatingAccountView.alpha = 0.0
//                            }, completion: { (completed) -> Void in
//                                self.creatingAccountIndicatorView.startAnimating();
//                                self.scrollView.isUserInteractionEnabled = true
//                                UIView.animate(withDuration: 0.2, animations: { () -> Void in
//                                    self.scrollView.alpha = 1.0
//                                })
//                            })
//                        }
//                    })
//                }
//                else {
//                    let errorAlert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
//                    errorAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
//                    self.present(errorAlert, animated: true, completion: nil)
//                    
//                    UIView.animate(withDuration: 0.2, animations: { () -> Void in
//                        self.creatingAccountView.alpha = 0.0
//                    }, completion: { (completed) -> Void in
//                        self.creatingAccountIndicatorView.startAnimating();
//                        self.scrollView.isUserInteractionEnabled = true
//                        UIView.animate(withDuration: 0.2, animations: { () -> Void in
//                            self.scrollView.alpha = 1.0
//                        })
//                    })
//                }
//            })
        }
    }
    
    // MARK: - Navigation
    @IBAction func returnToCreateAccountVC(_ segue: UIStoryboardSegue) {
        // Nothing for now
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "Show Privacy Policy" {
            // Do nothing for now :)
        }
    }
 

}
