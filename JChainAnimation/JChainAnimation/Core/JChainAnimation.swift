//
//  JChainAnimation.swift
//  JChainAnimation
//
//  Created by jams on 2019/9/20.
//  Copyright © 2019 jams. All rights reserved.
//

import UIKit


extension UIView {
    
    public class func animateAndChain(withDuration duration:TimeInterval, delay:TimeInterval, options:UIView.AnimationOptions, animations: @escaping ()->Void, completion:((Bool)->Void)?) ->JAnimationFuture {
        let currentAnimation = JAnimationFuture()
        currentAnimation.duration = duration
        currentAnimation.delay = delay
        currentAnimation.options = options
        currentAnimation.animations = animations
        currentAnimation.completion = completion
        
        currentAnimation.nextAnimation = JAnimationFuture()
        currentAnimation.nextAnimation!.previousAnimation = currentAnimation
        currentAnimation.run()
        
        JAnimationFuture.animations.append(currentAnimation)
        
        return currentAnimation.nextAnimation!
    }
    
    public class func animateAndChain(withDuration duration:TimeInterval, delay:TimeInterval, usingSpringWithDamping springDamping:CGFloat, initialVelocity springVelocity:CGFloat, options:UIView.AnimationOptions, animations:@escaping ()->Void, completion:((Bool)->Void)?) -> JAnimationFuture {
        let currentAnimation = JAnimationFuture()
        currentAnimation.duration = duration
        currentAnimation.delay = delay
        currentAnimation.options = options
        currentAnimation.springDamping = springDamping
        currentAnimation.springVelocity = springVelocity
        currentAnimation.animations = animations
        currentAnimation.completion = completion
        
        currentAnimation.nextAnimation = JAnimationFuture()
        currentAnimation.nextAnimation!.previousAnimation = currentAnimation
        currentAnimation.run()
        
        JAnimationFuture.animations.append(currentAnimation)
        
        return currentAnimation.nextAnimation!
    }
    
}
