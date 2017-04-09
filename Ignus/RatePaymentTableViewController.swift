//
//  RatePaymentTableViewController.swift
//  Ignus
//
//  Created by Anant Jain on 4/3/17.
//  Copyright © 2017 Anant Jain. All rights reserved.
//

import UIKit

protocol RatePaymentTableViewControllerDelegate: class {
    func finishedRating(ratePaymentTVC: RatePaymentTableViewController)
}

class RatePaymentTableViewController: UITableViewController {
    
    @IBOutlet weak var greenCell: UITableViewCell!
    @IBOutlet weak var yellowCell: UITableViewCell!
    @IBOutlet weak var redCell: UITableViewCell!
    
    enum Rating {
        case green, yellow, red, none
        
        init(indexPath: IndexPath) {
            switch (indexPath as NSIndexPath).row {
            case 0:
                self = .green
            case 1:
                self = .yellow
            case 2:
                self = .red
            default:
                self = .none
            }
        }
    }
    
    var rating = Rating.none
    var paymentToRate: [String: Any]!
    
    weak var delegate: RatePaymentTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Adds appropriate selection view to cells
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.3)
        greenCell.selectedBackgroundView = backgroundView
        yellowCell.selectedBackgroundView = backgroundView
        redCell.selectedBackgroundView = backgroundView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneRating(_ sender: AnyObject) {
        var paymentRating: String!
        
        if rating == .green {
            paymentRating = Constants.PaymentRating.Green
        }
        else if rating == .yellow {
            paymentRating = Constants.PaymentRating.Yellow
        }
        else if rating == .red {
            paymentRating = Constants.PaymentRating.Red
        }
        
        // TODO: complete payment
        
        self.delegate?.finishedRating(ratePaymentTVC: self)
    }

    // MARK: - Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        rating = Rating(indexPath: indexPath)
        
        greenCell.accessoryType = rating == .green ? .checkmark : .none
        yellowCell.accessoryType = rating == .yellow ? .checkmark : .none
        redCell.accessoryType = rating == .red ? .checkmark : .none
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.navigationItem.rightBarButtonItem!.isEnabled = true
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer = view as! UITableViewHeaderFooterView
        footer.textLabel?.font = UIFont(name: "Gotham-Book", size: 13)
    }

}
