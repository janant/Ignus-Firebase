//
//  FriendsNavigationViewController.swift
//  Ignus
//
//  Created by Anant Jain on 12/31/16.
//  Copyright © 2016 Anant Jain. All rights reserved.
//

import UIKit

class FriendsNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(red: 49/255, green: 49/255, blue: 49/255, alpha: 1.0)
        self.navigationBar.backgroundColor = UIColor(red: 49/255, green: 49/255, blue: 49/255, alpha: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
