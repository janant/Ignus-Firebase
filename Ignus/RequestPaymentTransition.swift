//
//  RequestPaymentTransition.swift
//  Ignus
//
//  Created by Anant Jain on 3/16/17.
//  Copyright © 2017 Anant Jain. All rights reserved.
//

import UIKit

class RequestPaymentTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var presenting: Bool
    var sentRequest: Bool
    
    init(presenting: Bool, sentRequest: Bool = false) {
        self.presenting = presenting
        self.sentRequest = sentRequest
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.18
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if presenting {
            animatePresentation(using: transitionContext)
        }
        else {
            if sentRequest {
                animateRequestSent(using: transitionContext)
            }
            else {
                animateCancel(using: transitionContext)
            }
        }
    }
    
    func animatePresentation(using transitionContext: UIViewControllerContextTransitioning) {
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
    
    func animateCancel(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from)
            else {
                transitionContext.completeTransition(false)
                return
        }
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: .curveEaseIn, animations: { () -> Void in
            fromVC.view.alpha = 0.0
            fromVC.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: { (completed) -> Void in
            transitionContext.completeTransition(true)
        })
    }
    
    func animateRequestSent(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from)
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        let translationY = fromVC.view.frame.origin.y + fromVC.view.frame.size.height
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: .curveEaseIn, animations: { () -> Void in
            fromVC.view.transform = CGAffineTransform(translationX: 0, y: -translationY)
        }, completion: { (completed) -> Void in
            transitionContext.completeTransition(true)
        })
    }
    
}
