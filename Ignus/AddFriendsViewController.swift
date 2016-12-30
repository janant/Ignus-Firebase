//
//  AddFriendsViewController.swift
//  Ignus
//
//  Created by Anant Jain on 12/29/16.
//  Copyright © 2016 Anant Jain. All rights reserved.
//

import UIKit

class AddFriendsViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var addFriendsTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var noResultsText: UILabel!
    
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
        
        for subview in searchBar.subviews[0].subviews {
            if let textField = subview as? UITextField {
                textField.font = UIFont(name: "Gotham-Medium", size: 14)
                textField.textColor = UIColor.white
                textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSFontAttributeName: UIFont(name: "Gotham-Medium", size: 14)!])
                break
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "User Cell", for: indexPath)
        return cell
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
