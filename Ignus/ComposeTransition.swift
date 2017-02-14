////
////  ComposeTransition.swift
////  
////
////  Created by Anant Jain on 7/27/15.
////
////
//
//import UIKit
//
//class ComposeTransition: NSObject, UIViewControllerAnimatedTransitioning {
//    
//    var presenting: Bool
//    var messageSent: Bool
//    
//    init(presenting: Bool, messageSent: Bool = false) {
//        self.presenting = presenting
//        self.messageSent = messageSent
//    }
//    
//    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
//        return 0.15
//    }
//    
//    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        if presenting {
//            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
//            let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
//            let containerView = transitionContext.containerView
//            
//            let darkView = UIView()
//            darkView.frame = UIScreen.main.bounds
//            darkView.backgroundColor = UIColor.black
//            darkView.alpha = 0.0
//            
//            toView.frame = CGRect(x: 20, y: 40, width: UIScreen.main.bounds.size.width - 40, height: 244)
//            toView.alpha = 0.0
//            toView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
//            toView.layer.cornerRadius = 10
//            toView.layer.masksToBounds = true
//            
//            let toVC = (transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! UINavigationController).topViewController as! ComposeMessageViewController
//            toVC.shadowView = darkView
//            
//            containerView.addSubview(darkView)
//            containerView.addSubview(toView)
//            
//            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: .curveEaseOut, animations: { () -> Void in
//                darkView.alpha = 0.7
//                toView.alpha = 1.0
//                toView.transform = CGAffineTransform.identity
//            }, completion: { (completed) -> Void in
//                transitionContext.completeTransition(true)
//            })
//        }
//        else {
//            let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
//            let fromVC = (transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! UINavigationController).topViewController as! ComposeMessageViewController
//            let darkView = fromVC.shadowView!
//            
//            if self.messageSent {
//                UIView.animate(withDuration: self.transitionDuration(using: transitionContext) * 1.5, delay: 0, options: .curveEaseOut, animations: { () -> Void in
//                    darkView.alpha = 0.0
//                    fromView.transform = CGAffineTransform(translationX: 0, y: -288)
//                    }, completion: { (completed) -> Void in
//                        transitionContext.completeTransition(true)
//                })
//                
//            }
//            else {
//                UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: .curveEaseOut, animations: { () -> Void in
//                    darkView.alpha = 0.0
//                    fromView.alpha = 0.0
//                    fromView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
//                    }, completion: { (completed) -> Void in
//                        transitionContext.completeTransition(true)
//                })
//            }
//        }
//    }
//}
