//
//  ProfileOptionsAnimation.swift
//  Ignus
//
//  Created by Anant Jain on 12/22/16.
//  Copyright © 2016 Anant Jain. All rights reserved.
//

import UIKit

class ProfileOptionsAnimation: NSObject, UIViewControllerAnimatedTransitioning {

    let presenting: Bool
    let initialPoint: CGPoint
    
    init(presenting: Bool, initialPoint: CGPoint) {
        self.presenting = presenting
        self.initialPoint = initialPoint
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return presenting ? 0.4 : 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if presenting {
            presentAnimation(transitionContext)
        }
        else {
            dismissAnimation(transitionContext)
        }
    }
    
    func presentAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toView = transitionContext.view(forKey: UITransitionContextViewKey.to),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else {
                transitionContext.completeTransition(false)
                return
        }
        
        let finalFrame = transitionContext.finalFrame(for: toVC)
        toView.frame = finalFrame
        
        let scaleTransformation = CGAffineTransform(scaleX: 0.01, y: 0.01)
        let translationTransformation = CGAffineTransform(translationX: initialPoint.x - finalFrame.midX, y: initialPoint.y - finalFrame.midY)
        
        toView.transform = scaleTransformation.concatenating(translationTransformation)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 20, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
            toView.transform = CGAffineTransform.identity
        }, completion: { (completed: Bool) -> Void in
            transitionContext.completeTransition(true)
        })
    }
    
    func dismissAnimation(_ transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from),
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
            else {
                transitionContext.completeTransition(false)
                return
        }
        
        let finalFrame = transitionContext.finalFrame(for: fromVC)
        
        let scaleTransformation = CGAffineTransform(scaleX: 0.01, y: 0.01)
        let translationTransformation = CGAffineTransform(translationX: initialPoint.x - finalFrame.midX, y: initialPoint.y - finalFrame.midY)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .curveEaseOut, animations: { () -> Void in
            fromView.transform = scaleTransformation.concatenating(translationTransformation)
        }) { (completed) -> Void in
            transitionContext.completeTransition(true)
        }
    }
}
