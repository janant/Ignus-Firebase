//
//  SignUpAnimation.swift
//  Ignus
//
//  Created by Anant Jain on 10/31/16.
//  Copyright © 2016 Anant Jain. All rights reserved.
//

import UIKit

class SignUpAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
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
            let toVC = transitionContext.viewController(forKey: .to) as? CreateAccountViewController,
            let fromVC = transitionContext.viewController(forKey: .from) as? LoginViewController
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        toVC.view.frame = transitionContext.finalFrame(for: toVC)
        
        if fromVC.traitCollection.horizontalSizeClass == .compact {
            toVC.backgroundBlurView.effect = nil
            toVC.scrollView.alpha = 0.0
            toVC.scrollView.transform = CGAffineTransform.init(translationX: 0, y: 44)
        }
        else {
            toVC.view.transform = CGAffineTransform.init(translationX: 0, y: fromVC.view.frame.height - toVC.view.frame.origin.y)
        }
        
        if fromVC.traitCollection.horizontalSizeClass == .compact {
            UIView.animate(withDuration: 0.5, animations: {
                toVC.backgroundBlurView.effect = UIBlurEffect(style: .light)
            })
            UIView.animate(withDuration: 0.25, delay: 0.4, options: .curveEaseOut, animations: {
                toVC.scrollView.alpha = 1.0
                toVC.scrollView.transform = CGAffineTransform.identity
            }, completion: { completed in
                transitionContext.completeTransition(true)
            })
        }
        else if fromVC.traitCollection.horizontalSizeClass == .regular {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
                toVC.view.transform = CGAffineTransform.identity
            }, completion: { completed in
                transitionContext.completeTransition(true)
            })
        }
    }
    
    func dismissAnimation(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: .from) as? CreateAccountViewController,
            let toVC = transitionContext.viewController(forKey: .to) as? LoginViewController
        else {
            transitionContext.completeTransition(false)
            return
        }
        
        if toVC.traitCollection.horizontalSizeClass == .compact {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: { 
                fromVC.scrollView.alpha = 0.0
                fromVC.scrollView.transform = CGAffineTransform.init(translationX: 0, y: 44)
            }, completion: nil)
            UIView.animate(withDuration: 0.5, delay: 0.15, options: .curveLinear, animations: {
                fromVC.backgroundBlurView.effect = nil
            }, completion: { completed in
                transitionContext.completeTransition(true)
            })
        }
        else if toVC.traitCollection.horizontalSizeClass == .regular {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
                fromVC.view.transform = CGAffineTransform.init(translationX: 0, y: toVC.view.frame.height - fromVC.view.frame.origin.y)
            }, completion: { completed in
                transitionContext.completeTransition(true)
            })
        }
    }

}
