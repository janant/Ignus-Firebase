//
//  AcknowledgementsViewController.swift
//  Ignus
//
//  Created by Anant Jain on 2/25/17.
//  Copyright © 2017 Anant Jain. All rights reserved.
//

import UIKit

class AcknowledgementsViewController: UIViewController {
    
    @IBOutlet weak var acknowledgementsTextview: UITextView!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Scrolls text view to the top
        acknowledgementsTextview.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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