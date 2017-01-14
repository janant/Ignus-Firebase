//
//  ProfileOptionsViewController.swift
//  Ignus
//
//  Created by Anant Jain on 12/22/16.
//  Copyright © 2016 Anant Jain. All rights reserved.
//

import UIKit

@objc protocol ProfileOptionsViewControllerDelegate: class {
    @objc optional func changeProfilePicture()
    @objc optional func changeCoverPicture()
    
    @objc optional func sendFriendRequest()
    @objc optional func cancelFriendRequest()
    
    @objc optional func respondToFriendRequest(_ response: String)
    @objc optional func unfriend()
    
    @objc optional func requestPayment()
    @objc optional func message()
}

class ProfileOptionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var responseTable: UITableView!
    
    weak var delegate: ProfileOptionsViewControllerDelegate?
    
    var profileType: String!
    
    var scrollEnabled = false {
        didSet {
            responseTable.isScrollEnabled = scrollEnabled
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        responseTable.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .light))
        responseTable.isScrollEnabled = scrollEnabled
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch profileType {
        case Constants.ProfileTypes.CurrentUser:
            return 2
        case Constants.ProfileTypes.Friend:
            return 3
        case Constants.ProfileTypes.User:
            return 1
        case Constants.ProfileTypes.PendingFriend:
            return 1
        case Constants.ProfileTypes.RequestedFriend:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Response Cell") else {
            return UITableViewCell()
        }
        
        cell.textLabel?.textColor = UIColor.white
        
        switch profileType {
        case Constants.ProfileTypes.CurrentUser:
            switch (indexPath as NSIndexPath).row {
            case 0:
                cell.textLabel?.text = "Change Profile\nPicture"
            case 1:
                cell.textLabel?.text = "Change Cover\nPhoto"
            default:
                break
            }
        case Constants.ProfileTypes.Friend:
            switch (indexPath as NSIndexPath).row {
            case 0:
                cell.textLabel?.text = "Message"
            case 1:
                cell.textLabel?.text = "Request Payment"
            case 2:
                cell.textLabel?.text = "Unfriend"
            default:
                break
            }
        case Constants.ProfileTypes.User:
            switch (indexPath as NSIndexPath).row {
            case 0:
                cell.textLabel?.text = "Send Friend\nRequest"
            default:
                break
            }
        case Constants.ProfileTypes.PendingFriend:
            switch (indexPath as NSIndexPath).row {
            case 0:
                cell.textLabel?.text = "Cancel Friend\nRequest"
            default:
                break
            }
        case Constants.ProfileTypes.RequestedFriend:
            switch (indexPath as NSIndexPath).row {
            case 0:
                cell.textLabel?.text = "Accept Friend\nRequest"
                cell.textLabel?.textColor = UIColor.green
            case 1:
                cell.textLabel?.text = "Decline Friend\nRequest"
                cell.textLabel?.textColor = UIColor.red
            default:
                break
            }
        default:
            break
        }
        
        cell.backgroundColor = UIColor.clear
        cell.backgroundView = nil
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 0.7)
        cell.selectedBackgroundView = selectedView
        
        return cell
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.isUserInteractionEnabled = false
        
        if profileType == Constants.ProfileTypes.CurrentUser {
            if (indexPath as NSIndexPath).row == 0 {
                self.dismiss(animated: true, completion: {(completed) -> Void in
                    self.delegate?.changeProfilePicture?()
                })
            }
            else if (indexPath as NSIndexPath).row == 1 {
                self.dismiss(animated: true, completion: {(completed) -> Void in
                    self.delegate?.changeCoverPicture?()
                })
            }
            
        }
        else if profileType == Constants.ProfileTypes.Friend {
            if (indexPath as NSIndexPath).row == 0 { // Message
                self.dismiss(animated: true, completion: { () -> Void in
                    self.delegate?.message?()
                })
            }
            else if (indexPath as NSIndexPath).row == 1 { // Request payment
                self.dismiss(animated: true, completion: { () -> Void in
                    self.delegate?.requestPayment!()
                })
            }
            else if (indexPath as NSIndexPath).row == 2 { // Unfriend
                self.delegate?.unfriend?()
                self.dismiss(animated: true, completion: nil)
            }
        }
        else if profileType == Constants.ProfileTypes.User {
            self.delegate?.sendFriendRequest?()
            self.dismiss(animated: true, completion: nil)
        }
        else if profileType == Constants.ProfileTypes.PendingFriend {
            self.delegate?.cancelFriendRequest?()
            self.dismiss(animated: true, completion: nil)
        }
        else if profileType == Constants.ProfileTypes.RequestedFriend {
            if (indexPath as NSIndexPath).row == 0 { // Accept friend request
                self.delegate?.respondToFriendRequest?(Constants.FriendRequestResponses.Accepted)
                self.dismiss(animated: true, completion: nil)
            }
            else if (indexPath as NSIndexPath).row == 1 { // Decline friend request
                self.delegate?.respondToFriendRequest?(Constants.FriendRequestResponses.Declined)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsets.zero
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
