//
//  MessagePresentation.swift
//  Ignus
//
//  Created by Anant Jain on 2/19/17.
//  Copyright © 2017 Anant Jain. All rights reserved.
//

import UIKit

class MessagePresentation: UIPresentationController {

    let shadowView = UIView()
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let safeAreaFrame = presentingViewController.view.safeAreaLayoutGuide.layoutFrame
        
        let intendedWidth: CGFloat = 500 // Want to make the view at most 500 pixels
        let maxPossibleWidth: CGFloat = safeAreaFrame.width - 40 // View width, 20px side margins
        
        let actualWidth = min(intendedWidth, maxPossibleWidth)
        
        let navigationBarHeight: CGFloat = {
            guard let navVC = presentedViewController as? UINavigationController else {
                return 44.0
            }
            return navVC.navigationBar.frame.size.height
        }()
        
        return CGRect(x: safeAreaFrame.midX - (actualWidth / 2), y: safeAreaFrame.origin.y + 20, width: actualWidth, height: 200 + navigationBarHeight)
    }
    
    override func presentationTransitionWillBegin() {
        // Sets up shadow view and adds to container view
        shadowView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
        shadowView.frame = presentingViewController.view.frame
        shadowView.alpha = 0.0
        
        // Adds corner radius to message view controller
        presentedViewController.view.layer.cornerRadius = 10
        presentedViewController.view.layer.masksToBounds = true
        
        if let container = self.containerView {
            container.addSubview(shadowView)
            container.addSubview(presentedViewController.view)
        }
        
        if let transitionCoordinator = presentingViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { (context) in
                self.shadowView.alpha = 1.0
            }, completion: nil)
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            shadowView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let transitionCoordinator = presentingViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { (context) in
                self.shadowView.alpha = 0.0
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            shadowView.removeFromSuperview()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            self.presentedViewController.view.frame = self.frameOfPresentedViewInContainerView
            self.shadowView.frame = self.presentingViewController.view.frame
        }, completion: nil)
    }

}
