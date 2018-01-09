//
//  ProfileOptionsPresentation.swift
//  Ignus
//
//  Created by Anant Jain on 12/22/16.
//  Copyright © 2016 Anant Jain. All rights reserved.
//

import UIKit

class ProfileOptionsPresentation: UIPresentationController {
    
    let shadowView = UIView()
    
    override func presentationTransitionWillBegin() {
        guard
            let container = containerView,
            let presentedView = presentedView
            else {
                return
        }
        
        shadowView.backgroundColor = UIColor.black
        shadowView.alpha = 0.0
        shadowView.frame = presentingViewController.view.frame
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        shadowView.addGestureRecognizer(tapRecognizer)
        
        presentedView.layer.cornerRadius = 10.0
        presentedView.layer.masksToBounds = true
        
        container.addSubview(shadowView)
        container.addSubview(presentedView)
        
        if let transitionCoordinator = presentingViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { (context) -> Void in
                self.shadowView.alpha = 0.4
            }, completion: nil)
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            shadowView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin() {
        presentedView?.isUserInteractionEnabled = false
        if let transitionCoordinator = presentingViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { (context) -> Void in
                self.shadowView.alpha = 0.0
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            shadowView.removeFromSuperview()
        }
    }
    
    @objc func dismiss() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let maxWidth: CGFloat = 250.0
        let maxHeight: CGFloat = {
            guard let presentedVC = presentedViewController as? ProfileOptionsViewController else {
                return 0.0
            }
            
            let numRows = CGFloat(presentedVC.tableView(presentedVC.responseTable, numberOfRowsInSection: 0))
            return numRows * 100.0
        }()
        
        let fromVCSafeArea = presentingViewController.view.safeAreaLayoutGuide.layoutFrame.insetBy(dx: 20.0, dy: 20.0)
        let width: CGFloat = min(fromVCSafeArea.width, maxWidth)
        let height: CGFloat = min(fromVCSafeArea.height, maxHeight)
        
        return CGRect(x: fromVCSafeArea.midX - (width / 2.0), y: fromVCSafeArea.midY - (height / 2.0),
                      width: width, height: height)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) -> Void in
            self.presentedView?.frame = self.frameOfPresentedViewInContainerView
            self.shadowView.frame = self.presentingViewController.view.frame
        }, completion: nil)
        
    }
    
}
