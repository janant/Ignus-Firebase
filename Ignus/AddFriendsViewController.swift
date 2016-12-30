//
//  AddFriendsViewController.swift
//  Ignus
//
//  Created by Anant Jain on 12/29/16.
//  Copyright © 2016 Anant Jain. All rights reserved.
//

import UIKit
import Firebase

class AddFriendsViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var addFriendsTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var noResultsText: UILabel!
    
    var allUserData: [[String: String]]?
    var searchResults = [[String: String]]()
    
    let usersDatabaseRef = FIRDatabase.database().reference().child("users")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Configures scroll inset and scroll position (so search bar is visible)
        addFriendsTable.contentInset = UIEdgeInsets(top: self.navigationController!.navigationBar.frame.size.height + UIApplication.shared.statusBarFrame.size.height, left: 0, bottom: 0, right: 0)
        addFriendsTable.setContentOffset(CGPoint(x: 0, y: -64), animated: false)
        
        // Configures table
        searchBar.keyboardAppearance = .dark
        addFriendsTable.separatorStyle = .none
        addFriendsTable.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .dark))
        addFriendsTable.backgroundView = nil
        addFriendsTable.isScrollEnabled = false
        
        // Sets the font/color for the search bar text and placeholder
        for subview in searchBar.subviews[0].subviews {
            if let textField = subview as? UITextField {
                textField.font = UIFont(name: "Gotham-Medium", size: 14)
                textField.textColor = UIColor.white
                textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSFontAttributeName: UIFont(name: "Gotham-Medium", size: 14)!])
                break
            }
        }
        
        // Notifications to handle keyboard appearances and disappearances
        NotificationCenter.default.addObserver(self, selector: #selector(AddFriendsViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddFriendsViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    // MARK: - Keyboard appearance notification methods
    
    func keyboardWillShow(_ sender: Notification) {
        // When keyboard shows, increase bottom scrolling inset (so user can scroll properly)
        if let userInfo = (sender as NSNotification).userInfo {
            if let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue?.height {
                addFriendsTable.contentInset.bottom = keyboardHeight
            }
        }
    }
    
    func keyboardWillHide(_ sender: Notification) {
        // When keyboard hides, set bottom inset back to zero
        addFriendsTable.contentInset.bottom = 0
        
        // If the user has scrolled past the content size, set the content offset back
        if addFriendsTable.contentOffset.y > addFriendsTable.contentSize.height {
            addFriendsTable.contentOffset.y = addFriendsTable.contentSize.height
        }
//        print("Content offset: \(addFriendsTable.contentOffset)")
//        print("Content size: \(addFriendsTable.contentSize)")
//        addFriendsTable.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "User Cell", for: indexPath)
        
        let user = searchResults[indexPath.row]
        
        guard
            let userImageView = cell.viewWithTag(1) as? UIImageView,
            let userNameLabel = cell.viewWithTag(2) as? UILabel,
            let userUsernameLabel = cell.viewWithTag(3) as? UILabel,
            let firstName = user["firstName"],
            let lastName = user["lastName"],
            let username = user["username"]
        else {
            return cell
        }
        
        // Sets default not loaded profile image
        // (since cells tend to be reused and the old profile shouldn't be used)
        userImageView.image = #imageLiteral(resourceName: "Not Loaded Profile")
        
        // Loads image and sets image view image to it
        let storageRef = FIRStorage.storage().reference()
        let profileRef = storageRef.child("User_Pictures/\(username)/profile.jpg")
        profileRef.data(withMaxSize: INT64_MAX, completion: { (data, error) in
            if error == nil && data != nil {
                UIView.transition(with: userImageView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    userImageView.image = UIImage(data: data!)
                }, completion: nil)
            }
        })
        
        // Sets name and username labels
        userNameLabel.text = firstName + " " + lastName
        userUsernameLabel.text = username
        
        // Sets background color (clear)
        cell.backgroundColor = UIColor.clear
        cell.backgroundView = UIView()
        
        // Sets selected background view
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.gray
        backgroundView.alpha = 0.5
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    // MARK: - Search bar delegate methods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        // Calls search text changed delegate method to requery based on current text
        if let searchText = searchBar.text {
            self.searchBar(searchBar, textDidChange: searchText)
        }
        
        // Generates appropriate placeholder text
        var placeholderText: String!
        if selectedScope == Constants.AddFriendsSearchBar.SearchByNameIndex {
            placeholderText = Constants.AddFriendsSearchBar.SearchByNamePlaceholderText
        }
        else if selectedScope == Constants.AddFriendsSearchBar.SearchByUsernameIndex {
            placeholderText = Constants.AddFriendsSearchBar.SearchByUsernamePlaceholderText
        }
        
        // Sets new attributed placeholder of search bar
        for subview in searchBar.subviews[0].subviews {
            if let textField = subview as? UITextField {
                textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSFontAttributeName: UIFont(name: "Gotham-Medium", size: 14)!])
                break
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Key to search for
        let childKey: String = {
            if searchBar.selectedScopeButtonIndex == Constants.AddFriendsSearchBar.SearchByNameIndex {
                return "firstName"
            }
            else if searchBar.selectedScopeButtonIndex == Constants.AddFriendsSearchBar.SearchByUsernameIndex {
                return "username"
            }
            else {
                return "firstName"
            }
        }()
        
        // Scrolls back to top
        addFriendsTable.setContentOffset(CGPoint(x: 0, y: -64), animated: true)
        
        if searchText.characters.count > 0 {
            
            // Gets user data if not already loaded
            if allUserData == nil {
                var handle: UInt = 0
                handle = usersDatabaseRef.observe(.value, with: { (snapshot) in
                    self.usersDatabaseRef.removeObserver(withHandle: handle)
                    guard let searchData = snapshot.value as? [String: [String: String]] else {
                        // If search data failed, display no results
                        UIView.animate(withDuration: 0.25, animations: {
                            self.noResultsText.alpha = 1.0
                            self.addFriendsTable.separatorStyle = .none
                        }, completion: { (completed) in
                            self.addFriendsTable.isScrollEnabled = false
                            self.addFriendsTable.reloadData()
                        })
                        
                        return
                    }
                    
                    // Store search results
                    self.allUserData = Array(searchData.values)
                    
                    // Sorts by first then last name
                    self.allUserData!.sort(by: { (first, second) -> Bool in
                        guard
                            let firstFirstName = first["firstName"],
                            let firstLastName = first["lastName"],
                            let secondFirstName = first["firstName"],
                            let secondLastName = first["lastName"]
                            else {
                                return true
                        }
                        
                        if firstFirstName == secondFirstName {
                            return firstLastName < secondLastName
                        }
                        else {
                            return firstFirstName < secondFirstName
                        }
                    })
                    
                    self.filterAndHandleData(searchText: searchText, childKey: childKey)
                })
            }
            else {
                self.filterAndHandleData(searchText: searchText, childKey: childKey)
            }
        }
        else {
            searchResults = [[String: String]]()
            
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.noResultsText.alpha = 0.0
                self.addFriendsTable.separatorStyle = .none
            })
            
            addFriendsTable.isScrollEnabled = false
            addFriendsTable.reloadData()
        }
    }
    
    func filterAndHandleData(searchText: String, childKey: String) {
        // Filters data based on search query
        searchResults = allUserData!.filter {
            guard let data = $0[childKey] else {
                return false
            }
            return data.lowercased().hasPrefix(searchText.lowercased())
        }
        
        addFriendsTable.reloadData()
        
        // Display results if there are users in the query
        if searchResults.count > 0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.noResultsText.alpha = 0.0
                self.addFriendsTable.separatorStyle = .singleLine
            }, completion: { (completed) in
                self.addFriendsTable.isScrollEnabled = true
            })
        }
        else {
            // Display no results
            UIView.animate(withDuration: 0.25, animations: {
                self.noResultsText.alpha = 1.0
                self.addFriendsTable.separatorStyle = .none
            }, completion: { (completed) in
                self.addFriendsTable.isScrollEnabled = false
            })
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
