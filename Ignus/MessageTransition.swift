//
//  MessageTransition.swift
//  Ignus
//
//  Created by Anant Jain on 2/19/17.
//  Copyright © 2017 Anant Jain. All rights reserved.
//

import UIKit

class MessageTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var presenting: Bool
    var isViewingMessage: Bool
    var sentMessage: Bool
    var sourceFrame: CGRect
    
    init(presenting: Bool, isViewingMessage: Bool = false, sentMessage: Bool = false, sourceFrame: CGRect = CGRect()) {
        self.presenting = presenting
        self.isViewingMessage = isViewingMessage
        self.sentMessage = sentMessage
        self.sourceFrame = sourceFrame
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if presenting && isViewingMessage {
            return 0.25
        }
        else {
            return 0.15
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if presenting {
            if isViewingMessage {
                viewMessagePresentAnimation(using: transitionContext)
            }
            else {
                composePresentAnimation(using: transitionContext)
            }
        }
        else {
            if sentMessage {
                sendMessageDismissAnimation(using: transitionContext)
            }
            else if isViewingMessage {
                viewMessageDismissAnimation(using: transitionContext)
            }
            else {
                composeDismissAnimation(using: transitionContext)
            }
        }
    }
    
    func composePresentAnimation(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toVC = transitionContext.viewController(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        // Sets final frame of toVC
        toVC.view.frame = transitionContext.finalFrame(for: toVC)
        
        // Transparent + increased scale for animation beginning
        toVC.view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        toVC.view.alpha = 0.0
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: .curveEaseOut, animations: { () -> Void in
            toVC.view.alpha = 1.0
            toVC.view.transform = CGAffineTransform.identity
        }, completion: { (completed) -> Void in
            transitionContext.completeTransition(true)
        })
    }
    
    func composeDismissAnimation(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
            else {
                transitionContext.completeTransition(false)
                return
        }
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: .curveEaseIn, animations: { () -> Void in
            fromVC.view.alpha = 0.0
            fromVC.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: { (completed) -> Void in
            if let tabBarVC = toVC as? UITabBarController {
                if let messagesNavVC = tabBarVC.viewControllers?[2] as? UINavigationController {
                    if let messagesVC = messagesNavVC.topViewController {
                        messagesVC.viewDidAppear(true)
                    }
                }
            }
            transitionContext.completeTransition(true)
        })
    }
    
    func sendMessageDismissAnimation(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        let translationY = fromVC.view.frame.origin.y + fromVC.view.frame.size.height
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: .curveEaseIn, animations: { () -> Void in
            fromVC.view.transform = CGAffineTransform(translationX: 0, y: -translationY)
        }, completion: { (completed) -> Void in
            if let tabBarVC = toVC as? UITabBarController {
                if let messagesNavVC = tabBarVC.viewControllers?[2] as? UINavigationController {
                    if let messagesVC = messagesNavVC.topViewController {
                        messagesVC.viewDidAppear(true)
                    }
                }
            }
            transitionContext.completeTransition(true)
        })
    }
    
    func viewMessagePresentAnimation(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toVC = transitionContext.viewController(forKey: .to)
            else {
                transitionContext.completeTransition(false)
                return
        }
        
        let finalFrame = transitionContext.finalFrame(for: toVC)
        toVC.view.frame = finalFrame
        
        // Transformations
        let transX: CGFloat = 0
        let transY: CGFloat = sourceFrame.midY - finalFrame.midY
        let scaleX: CGFloat = sourceFrame.size.width / finalFrame.size.width
        let scaleY: CGFloat = sourceFrame.size.height / finalFrame.size.height
        
        toVC.view.transform = CGAffineTransform(translationX: transX, y: transY).scaledBy(x: scaleX, y: scaleY)
        toVC.view.alpha = 0.0
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 20, options: .curveEaseOut, animations: {
            toVC.view.transform = CGAffineTransform.identity
            toVC.view.alpha = 1.0
        }) { (completed) in
            transitionContext.completeTransition(true)
        }
    }
    
    func viewMessageDismissAnimation(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from)
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        let finalFrame = transitionContext.finalFrame(for: fromVC)
        
        // Transformations
        let transX: CGFloat = 0
        let transY: CGFloat = sourceFrame.midY - finalFrame.midY
        let scaleX: CGFloat = sourceFrame.size.width / finalFrame.size.width
        let scaleY: CGFloat = sourceFrame.size.height / finalFrame.size.height
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0.0, options: .curveEaseIn, animations: { 
            fromVC.view.transform = CGAffineTransform(translationX: transX, y: transY).scaledBy(x: scaleX, y: scaleY)
            fromVC.view.alpha = 0.0
        }) { (completed) in
            transitionContext.completeTransition(true)
        }
    }

}
