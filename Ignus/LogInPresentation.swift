//
//  LogInPresentation.swift
//  Ignus
//
//  Created by Anant Jain on 12/10/16.
//  Copyright © 2016 Anant Jain. All rights reserved.
//

import UIKit

class LogInPresentation: UIPresentationController {

    let shadowView = UIView()
    
    override func presentationTransitionWillBegin() {
        // Sets up shadow view and adds to container view
        shadowView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        shadowView.frame = presentingViewController.view.frame
        shadowView.alpha = 0.7
        
        if let container = self.containerView {
            container.insertSubview(presentingViewController.view, at: 0)
            container.insertSubview(shadowView, at: 0)
            container.insertSubview(presentedViewController.view, at: 0)
        }
        
        // Fades out the shadow view
        UIView.animate(withDuration: 0.35, delay: 0.3, options: .curveEaseIn, animations: { () -> Void in
            self.shadowView.alpha = 0.0
        }, completion: nil)
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            shadowView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: { () -> Void in
            self.shadowView.alpha = 0.7
        }, completion: nil)
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
            self.shadowView.frame = self.presentedViewController.view.frame
            self.presentingViewController.view.transform = CGAffineTransform(translationX: 0, y: size.height)
        }, completion: nil)
    }
    
}
