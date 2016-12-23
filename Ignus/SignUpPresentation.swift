//
//  SignUpPresentation.swift
//  Ignus
//
//  Created by Anant Jain on 10/31/16.
//  Copyright © 2016 Anant Jain. All rights reserved.
//

import UIKit

class SignUpPresentation: UIPresentationController {
    
    let shadowView = UIView()
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let loginVCFrame = presentingViewController.view.frame
        
        if traitCollection.horizontalSizeClass == .compact {
            return loginVCFrame
        }
        else {
            // Ideal height and width
            let intendedWidth = 500
            let intendedHeight = 680
            
            // In case the window is too small to fit ideal size, reduces size appropriately
            let actualWidth = min(intendedWidth, Int(presentingViewController.view.frame.width))
            let actualHeight = min(intendedHeight, Int(presentingViewController.view.frame.height))
            
            // Rectangle with the adjusted frame
            return CGRect(x: Int(loginVCFrame.midX) - (actualWidth / 2), y: Int(loginVCFrame.midY) - (actualHeight / 2), width: actualWidth, height: actualHeight)
        }
    }
    
    override func presentationTransitionWillBegin() {
        presentedViewController.view.layer.masksToBounds = true
        setUpPresentedViewCornerRadius()
        
        // Sets up shadow view and adds to container view
        shadowView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
        shadowView.frame = presentingViewController.view.frame
        shadowView.alpha = 0.0
        if let container = self.containerView {
            container.addSubview(shadowView)
            container.addSubview(presentedViewController.view)
        }
        if presentingViewController.traitCollection.horizontalSizeClass == .regular {
            if let transitionCoordinator = presentingViewController.transitionCoordinator {
                transitionCoordinator.animate(alongsideTransition: { (context) in
                    self.shadowView.alpha = 1.0
                }, completion: nil)
            }
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            shadowView.removeFromSuperview()
        }
    }

    override func dismissalTransitionWillBegin() {
        if presentingViewController.traitCollection.horizontalSizeClass == .regular {
            if let transitionCoordinator = presentingViewController.transitionCoordinator {
                transitionCoordinator.animate(alongsideTransition: { (context) in
                    self.shadowView.alpha = 0.0
                }, completion: nil)
            }
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setUpPresentedViewCornerRadius()
        if presentingViewController.traitCollection.horizontalSizeClass == .compact {
            self.shadowView.alpha = 0.0
        }
        else {
            self.shadowView.alpha = 1.0
        }
    }
    
    func setUpPresentedViewCornerRadius() {
        if presentingViewController.traitCollection.horizontalSizeClass == .regular {
            presentedViewController.view.layer.cornerRadius = 15
        }
        else {
            presentedViewController.view.layer.cornerRadius = 0
        }
    }
}
