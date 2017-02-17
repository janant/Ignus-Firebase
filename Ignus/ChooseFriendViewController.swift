//
//  ChooseFriendViewController.swift
//  Ignus
//
//  Created by Anant Jain on 12/25/16.
//  Copyright © 2016 Anant Jain. All rights reserved.
//

import UIKit
import Firebase

protocol ChooseFriendViewControllerDelegate {
    func choseFriend(_ friend: String)
}

class ChooseFriendViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var friendsCollectionView: UICollectionView!
    @IBOutlet weak var friendsLoadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var noFriendsLabel: UILabel!
    
    var friendsData = [[String: String]]()
    
    var delegate: ChooseFriendViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Gets all friend data from the database
        let usersDatabaseReference = FIRDatabase.database().reference().child("users")
        IgnusBackend.getFriends { (friends) in
            DispatchQueue.global(qos: .background).sync {
                self.getFriendsData(friends: friends, startIndex: 0, usersDatabaseReference: usersDatabaseReference)
            }
        }
    }
    
    func getFriendsData(friends: [String], startIndex: Int, usersDatabaseReference: FIRDatabaseReference) {
        if startIndex >= friends.count {
            DispatchQueue.main.async {
                // Sorts friends by first name
                self.friendsData = self.friendsData.sorted {
                    guard
                        let firstFirstName = $0["firstName"],
                        let secondFirstName = $1["firstName"]
                    else {
                        return false
                    }
                    
                    return firstFirstName < secondFirstName
                }
                
                self.friendsCollectionView.reloadData()
                
                if (self.friendsData.count > 0) {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.friendsCollectionView.alpha = 1.0
                        self.friendsLoadingIndicatorView.alpha = 0.0
                    }, completion: { (completed) in
                        self.friendsLoadingIndicatorView.stopAnimating()
                        self.friendsCollectionView.isUserInteractionEnabled = true
                    })
                }
                else {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.noFriendsLabel.alpha = 1.0
                        self.friendsLoadingIndicatorView.alpha = 0.0
                    }, completion: { (completed) in
                        self.friendsLoadingIndicatorView.stopAnimating()
                    })
                }
            }
        }
        else {
            let friend = friends[startIndex]
            usersDatabaseReference.child(friend).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let friendData = snapshot.value as? [String: String] else {
                    return
                }
                self.friendsData.append(friendData)
                self.getFriendsData(friends: friends, startIndex: startIndex + 1, usersDatabaseReference: usersDatabaseReference)
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Collection view data source methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Friend Cell", for: indexPath)
        let friendData = friendsData[indexPath.row]
        
        guard
            let profileImage = cell.viewWithTag(1) as? UIImageView,
            let nameLabel = cell.viewWithTag(2) as? UILabel,
            let usernameLabel = cell.viewWithTag(3) as? UILabel,
            let friendUsername = friendData["username"]
        else {
            return cell
        }
        
        let profileRef = FIRStorage.storage().reference().child("User_Pictures/\(friendUsername)/profile.jpg")
        profileRef.data(withMaxSize: INT64_MAX, completion: { (data, error) in
            if error == nil && data != nil {
                UIView.transition(with: profileImage, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    profileImage.image = UIImage(data: data!)
                }, completion: nil)
            }
        })
        
        nameLabel.text = friendData["firstName"]
        usernameLabel.text = friendData["lastName"]
        
        return cell
    }
    
    // MARK: - Collection view delegate methods
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        // Highlights the highlight view of the cell
        if let highlightView = friendsCollectionView.cellForItem(at: indexPath)?.viewWithTag(4) {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                highlightView.alpha = 1.0
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Highlights the highlight view of the cell
        if let highlightView = friendsCollectionView.cellForItem(at: indexPath)?.viewWithTag(4) {
            highlightView.alpha = 1.0
        }
        
        if let selectedFriendUsername = friendsData[indexPath.row]["username"] {
            self.delegate?.choseFriend(selectedFriendUsername)
            performSegue(withIdentifier: "Return to Previous", sender: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        // Unhighlights the highlight view of the cell
        if let highlightView = friendsCollectionView.cellForItem(at: indexPath)?.viewWithTag(4) {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                highlightView.alpha = 0.0
            })
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
