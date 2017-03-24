//
//  RequestPaymentPresentation.swift
//  Ignus
//
//  Created by Anant Jain on 3/16/17.
//  Copyright © 2017 Anant Jain. All rights reserved.
//

import UIKit

class RequestPaymentPresentation: UIPresentationController {
    
    let shadowView = UIView()
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let presentingFrame = presentingViewController.view.frame
        let intendedWidth: CGFloat = 500 // Want to make the view at most 500 pixels wide
        let intendedHeight: CGFloat = 600 // Want to make the view at most 500 pixels tall
        
        let maxPossibleWidth: CGFloat = presentingFrame.width - 40 // View width, 20px side margins
        let maxPossibleHeight: CGFloat = presentingFrame.height - 50 // View height w/ margins
        
        let actualWidth = min(intendedWidth, maxPossibleWidth)
        let actualHeight = min(intendedHeight, maxPossibleHeight)
        
        return CGRect(x: presentingFrame.midX - (actualWidth / 2), y: 30, width: actualWidth, height: actualHeight)
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
