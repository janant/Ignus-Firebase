//
//  LoginViewController.swift
//  Ignus
//
//  Created by Anant Jain on 10/28/16.
//  Copyright © 2016 Anant Jain. All rights reserved.
//

import UIKit
import Firebase
import LocalAuthentication

class LoginViewController: UIViewController, UITextFieldDelegate, UIViewControllerTransitioningDelegate, CreateAccountViewControllerDelegate {

    // Launch animation views
    @IBOutlet weak var launchBackgroundImageView: UIImageView!
    @IBOutlet weak var launchLogoImageView: UIImageView!
    
    // Some stack views needed for text view animation
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var inputTextViewsStackView: UIStackView!
    @IBOutlet weak var buttonsStackView: UIStackView!
    
    
    // Background GIF that plays
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    // Logo views
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var logoLine: UIView!
    @IBOutlet weak var logoTextView: UILabel!
    @IBOutlet weak var loginLoadingCircle: UIImageView!
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var logoStackView: UIStackView!
    
    // Username and password text fields and containing views
    @IBOutlet weak var inputStackView: UIStackView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextFieldBox: UIView!
    @IBOutlet weak var passwordTextFieldBox: UIView!
    
    // Buttons at the bottom
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    // Keeps track of whether the entrance animation from the launch screen was played.
    var didAnimateEntrance = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - View controller lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (!didAnimateEntrance) {
            // Appropriate automatic login if the user is already logged in
            if let currentUser = FIRAuth.auth()?.currentUser,
               let loginOption = UserDefaults.standard.string(forKey: "LoginOptions") {
                
                usernameTextField.text = currentUser.displayName
                
                switch loginOption {
                case Constants.LoginOptions.AutomaticLogin:
                    // Automatically log in
                    let loginDelay: TimeInterval = 0.25;
                    perform(#selector(LoginViewController.skipAnimatedEntrance), with: nil, afterDelay: loginDelay)
                case Constants.LoginOptions.TouchID:
                    let context = LAContext()
                    var error: NSError?
                    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Authenticate to login to your Ignus account.", reply: { (success, error) in
                            DispatchQueue.main.async {
                                if success {
                                    self.perform(#selector(LoginViewController.skipAnimatedEntrance), with: nil, afterDelay: 0.35)
                                }
                                else {
                                    self.animateEntrance(shouldResetLoginOptions: false)
                                }
                            }
                        })
                    }
                    else {
                        self.animateEntrance(shouldResetLoginOptions: false)
                    }
                case Constants.LoginOptions.RequirePassword:
                    animateEntrance(shouldResetLoginOptions: false)
                default:
                    try? FIRAuth.auth()?.signOut()
                    animateEntrance(shouldResetLoginOptions: true)
                }
            }
            else {
                animateEntrance(shouldResetLoginOptions: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Sets the placeholder text in the text boxes to white color
        usernameTextField.attributedPlaceholder = NSAttributedString(string: usernameTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.white])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.white])
        
        // Creates animation for background and plays animation
        var animationImages : [UIImage] = Array()
        for i in 1...23 {
            animationImages.append(UIImage(named: String(format: "%d", i))!)
        }
        backgroundImageView.animationImages = animationImages
        backgroundImageView.animationDuration = 2.0
        backgroundImageView.startAnimating()
        
        // Adds parallax effect
        let parallaxX = UIInterpolatingMotionEffect(keyPath: "center.x", type: UIInterpolatingMotionEffectType.tiltAlongHorizontalAxis)
        let parallaxY = UIInterpolatingMotionEffect(keyPath: "center.y", type: UIInterpolatingMotionEffectType.tiltAlongVerticalAxis)
        
        parallaxX.minimumRelativeValue = -15
        parallaxX.maximumRelativeValue = 15
        
        parallaxY.minimumRelativeValue = -15
        parallaxY.maximumRelativeValue = 15
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [parallaxX, parallaxY]
        
        logoImageView.addMotionEffect(group)
        logoLine.addMotionEffect(group)
        logoTextView.addMotionEffect(group)
        usernameTextFieldBox.addMotionEffect(group)
        passwordTextFieldBox.addMotionEffect(group)
        logInButton.addMotionEffect(group)
        createAccountButton.addMotionEffect(group)
    }
    
    func animateEntrance(shouldResetLoginOptions: Bool) {
        // Ensures automatic login is disabled since user is not logged in (if allowed)
        if shouldResetLoginOptions {
            UserDefaults.standard.set(Constants.LoginOptions.None, forKey: "LoginOptions")
            UserDefaults.standard.synchronize()
        }
        
        // Sets up views for animation
        let logoFrame = self.view.convert(logoImageView.frame, from: logoView)
        logoStackView.alpha = 0.0
        inputStackView.alpha = 0.0
        
        // Transformation variables for the logo
        let transX = logoFrame.midX - self.launchLogoImageView.frame.midX
        let transY = logoFrame.midY - self.launchLogoImageView.frame.midY
        let scaleX = logoFrame.width / self.launchLogoImageView.frame.width
        let scaleY = logoFrame.height / self.launchLogoImageView.frame.height
        let transformation = CGAffineTransform(translationX: transX, y: transY).scaledBy(x: scaleX, y: scaleY)
        
        // Animation length variables
        let animationDuration: TimeInterval = 0.75
        let animationDelay: TimeInterval = 0.25
        let animationOverlap: TimeInterval = 0.3
        
        UIView.animate(withDuration: animationDuration, delay: animationDelay, options: UIViewAnimationOptions(), animations: {
            self.launchLogoImageView.transform = transformation
            self.launchBackgroundImageView.alpha = 0.0
        }, completion: nil)
        
        UIView.animate(withDuration: 0.25, delay: animationDuration + animationDelay - animationOverlap, options: UIViewAnimationOptions(), animations: {
            self.logoStackView.alpha = 1.0
            self.inputStackView.alpha = 1.0
        }, completion: { (finished) in
            self.perform(#selector(LoginViewController.removeEntranceAnimationComponents), with: nil, afterDelay: animationOverlap)
            
            self.didAnimateEntrance = true
        })
    }
    
    @objc private func removeEntranceAnimationComponents() {
        self.logoImageView.alpha = 1.0
        self.launchBackgroundImageView.removeFromSuperview()
        self.launchLogoImageView.removeFromSuperview()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // If main stack view was raised for editing, hide/show views and change offset
        if mainStackView.transform != CGAffineTransform.identity {
            let alphaValue: CGFloat = traitCollection.horizontalSizeClass == .regular ? 1.0 : 0.0
            self.logoStackView.alpha = alphaValue
            self.buttonsStackView.alpha = alphaValue
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // If main stack view was raised for editing, set new offset
        if mainStackView.transform != CGAffineTransform.identity {
            // Set new frame as its animating
            coordinator.animate(alongsideTransition: { (context) in
                let textFieldFrameInMainStackView = self.mainStackView.convert(self.usernameTextField.frame, from: self.inputTextViewsStackView)
                let desiredOffset: CGFloat = self.view.frame.height / 4.0
                let currentOffset: CGFloat = textFieldFrameInMainStackView.height - desiredOffset
                self.mainStackView.transform = CGAffineTransform(translationX: 0, y: currentOffset)
            }, completion: nil)
        }
    }
    
    // MARK: - Text field delegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === usernameTextField {
            usernameTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        }
        else if textField === passwordTextField {
            passwordTextField.resignFirstResponder()
            
            dismissTextInputs(passwordTextField)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Only animate if is username or password, and if not already animated upward
        if (textField === usernameTextField || textField === passwordTextField) && mainStackView.transform == CGAffineTransform.identity {
            // Calculates offset to shift upward (to make sure keyboard doesn't cover text fields
            let textFieldFrameInMainStackView = mainStackView.convert(usernameTextField.frame, from: inputTextViewsStackView)
            let desiredOffset: CGFloat = self.view.frame.height / 4.0
            let currentOffset: CGFloat = textFieldFrameInMainStackView.height - desiredOffset
            
            // Animates views upward
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 10, initialSpringVelocity: 25, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
                self.mainStackView.transform = CGAffineTransform(translationX: 0, y: currentOffset)
            }, completion: nil)
            
            // Hides irrelevant views when editing, if horizontally compact
            if traitCollection.horizontalSizeClass == .compact {
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.logoStackView.alpha = 0.0
                    self.buttonsStackView.alpha = 0.0
                })
            }
        }
    }
    
    // MARK: - Keyboard present/dismiss methods
    
    @IBAction func dismissTextInputs(_ sender: AnyObject?) {
        self.view.endEditing(true)
        
        // Animates views downward
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 10, initialSpringVelocity: 25, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
            self.mainStackView.transform = CGAffineTransform.identity
        }, completion: nil)
        
        // Shows relevant views again
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.logoStackView.alpha = 1.0
            self.buttonsStackView.alpha = 1.0
        })
    }
    
    @IBAction func enterUsernameTap(_ sender: Any) {
        usernameTextField.becomeFirstResponder()
    }
    
    @IBAction func enterPasswordTap(_ sender: Any) {
        passwordTextField.becomeFirstResponder()
    }
    
    func skipAnimatedEntrance() {
        self.didAnimateEntrance = true
        
        performSegue(withIdentifier: "Log In", sender: nil)
        perform(#selector(LoginViewController.removeEntranceAnimationComponents), with: nil, afterDelay: 2.0)
    }
    
    func createdAccount(withUsername username: String, andPassword password: String) {
        usernameTextField.text = username
        passwordTextField.text = password
        logIn(username)
    }
    
    // MARK: - Transitioning delegate methods
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented is CreateAccountViewController {
            return SignUpAnimation(presenting: true)
        }
        else if presented is UITabBarController {
            return LogInAnimation(presenting: true)
        }
        return nil
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed is CreateAccountViewController {
            return SignUpAnimation(presenting: false)
        }
        else if dismissed is UITabBarController {
            return LogInAnimation(presenting: false)
        }
        return nil
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        if presented is CreateAccountViewController {
            return SignUpPresentation(presentedViewController: presented, presenting: presenting)
        }
        else if presented is UITabBarController {
            return LogInPresentation(presentedViewController: presented, presenting: presenting)
        }
        return nil
    }

    @IBAction func logIn(_ sender: Any) {
        dismissTextInputs(sender as AnyObject)
        
        // Get username and password
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            let errorAlert = UIAlertController(title: "Error", message: "Please enter a valid username and password.", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
            present(errorAlert, animated: true, completion: nil)
            return
        }
        
        // Login animation
        beginLoginAnimation()
        
        // Gets the user's email for Firebase authentication
        let ref = FIRDatabase.database().reference()
        ref.child("users").child(username).observeSingleEvent(of: .value, with: { (snapshot) in
            guard
                let userInfo = snapshot.value as? [String: String],
                let email = userInfo["email"]
            else {
                let errorAlert = UIAlertController(title: "Error", message: "The username specified does not exist.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
                self.endLoginAnimation()
                
                return
            }
            
            // Attempt to log in
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    // Ensure the user is automatically logged in from now on,
                    // if no option previously set.
                    if let loginOption = UserDefaults.standard.string(forKey: "LoginOptions") {
                        if loginOption == Constants.LoginOptions.None {
                            UserDefaults.standard.set(Constants.LoginOptions.AutomaticLogin, forKey: "LoginOptions")
                            UserDefaults.standard.synchronize()
                        }
                    }
                    else {
                        UserDefaults.standard.set(Constants.LoginOptions.AutomaticLogin, forKey: "LoginOptions")
                        UserDefaults.standard.synchronize()
                    }
                    
                    // Successfully logged in
                    self.performSegue(withIdentifier: "Log In", sender: sender)
                    self.perform(#selector(LoginViewController.endLoginAnimation), with: nil, afterDelay: 2.0)
                }
                else {
                    let errorAlert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                    self.endLoginAnimation()
                }
            })
        }) { (error) in
            // Do nothing
            let errorAlert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
            self.present(errorAlert, animated: true, completion: nil)
            self.endLoginAnimation()
        }
    }
    
    func beginLoginAnimation() {
        // Fade out other views
        UIView.animate(withDuration: 0.25, animations: {
            self.inputStackView.alpha = 0.0
            self.logoLine.alpha = 0.0
            self.logoTextView.alpha = 0.0
        })
        
        // Center the logo view
        let logoFrame = self.view.convert(self.logoView.frame, from: self.logoStackView)
        let offsetX = self.view.frame.midX - logoFrame.midX
        let offsetY = self.view.frame.midY - logoFrame.midY
        
        UIView.animate(withDuration: 0.15, animations: {
            self.loginLoadingCircle.alpha = 1.0
            self.logoView.transform = CGAffineTransform(translationX: offsetX, y: offsetY)
        })
        
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0.0
        animation.toValue = 2 * M_PI
        animation.duration = 1.0
        animation.repeatCount = 999.0
        self.loginLoadingCircle.layer.add(animation, forKey: "rotationAnimation")
    }
    
    func endLoginAnimation() {
        UIView.animate(withDuration: 0.15, animations: {
            self.logoView.transform = CGAffineTransform.identity
            self.loginLoadingCircle.alpha = 0.0
        }, completion: { (completed) in
            self.loginLoadingCircle.layer.removeAllAnimations()
            
            UIView.animate(withDuration: 0.4, animations: {
                self.logoLine.alpha = 1.0
                self.logoTextView.alpha = 1.0
                self.inputStackView.alpha = 1.0
            })
        })
        
        self.passwordTextField.text = ""
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "Create Account" {
            dismissTextInputs(sender as AnyObject)
            if let createAccountVC = segue.destination as? CreateAccountViewController {
                createAccountVC.delegate = self
                
                createAccountVC.transitioningDelegate = self
                createAccountVC.modalPresentationStyle = .custom
            }
        }
        else if segue.identifier == "Log In" {
            dismissTextInputs(sender as AnyObject)
            if let tabBarVC = segue.destination as? UITabBarController {
                tabBarVC.transitioningDelegate = self
                tabBarVC.modalPresentationStyle = .custom
            }
        }
        
    }
 

}
