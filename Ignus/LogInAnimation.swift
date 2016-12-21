//
//  LogInAnimation.swift
//  Ignus
//
//  Created by Anant Jain on 12/10/16.
//  Copyright © 2016 Anant Jain. All rights reserved.
//

import UIKit

class LogInAnimation: NSObject, UIViewControllerAnimatedTransitioning {

    var presenting: Bool
    
    init(presenting: Bool) {
        self.presenting = presenting
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.75
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if presenting {
            presentAnimation(using: transitionContext)
        }
        else {
            dismissAnimation(using: transitionContext)
        }
    }
    
    func presentAnimation(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toVC = transitionContext.viewController(forKey: .to),
            let fromVC = transitionContext.viewController(forKey: .from) as? LoginViewController
            else {
                transitionContext.completeTransition(false)
                return
        }
        
        toVC.view.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        
        // Slides the login screen down
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            fromVC.view.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
        }, completion: nil)
        
        // Grows the main screen
        UIView.animate(withDuration: 0.35, delay: 0.3, options: .curveEaseIn, animations: { () -> Void in
            toVC.view.transform = CGAffineTransform.identity
        }, completion: { (completed: Bool) -> Void in
            
            fromVC.endLoginAnimation()
            
            transitionContext.completeTransition(true)
        })
    }
    
    func dismissAnimation(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) as? LoginViewController
            else {
                transitionContext.completeTransition(false)
                return
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: { () -> Void in
            fromVC.view.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0.15, options: .curveEaseOut, animations: { () -> Void in
            toVC.view.transform = CGAffineTransform.identity
        }, completion: { (completed: Bool) -> Void in
            transitionContext.completeTransition(true)
            UIApplication.shared.keyWindow?.addSubview(toVC.view)
        })
    }
}
