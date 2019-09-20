//
//  JAnimationFuture.swift
//  JChainAnimation
//
//  Created by jams on 2019/9/20.
//  Copyright © 2019 jams. All rights reserved.
//

import UIKit

public class JAnimationFuture: Equatable{
    
    var duration: TimeInterval = 0.0
    var options: UIView.AnimationOptions = []
    var delay: TimeInterval = 0.0
    var animations: (()->Void)?
    var completion: ((Bool)->Void)?
    var springDamping: CGFloat = 0.0
    var springVelocity: CGFloat = 0.0
    
    var identifier: String
    
    private var loopChain = false
    
    private static var cancelCompletions: [String: ()->Void] = [:]
    
    var previousAnimation: JAnimationFuture? {
        didSet {
            if let prev = previousAnimation {
                identifier = prev.identifier
            }
        }
    }
    
    var nextAnimation: JAnimationFuture?
    
    
    init() {
        identifier = UUID().uuidString
    }
    
    public static var animations: [JAnimationFuture] = []
    
    @discardableResult
    func animate(withDuration duration:TimeInterval, animations: @escaping ()->Void) -> JAnimationFuture {
        return animate(withDuration: duration, animations: animations, complection: completion)
    }
    
    @discardableResult
    func animate(withDuration duration:TimeInterval, animations: @escaping ()->Void, complection:((Bool)->Void)?) -> JAnimationFuture {
        return animate(withDuration: duration, delay: 0.0, options:[], animations: animations, complection: complection)
    }
    
    @discardableResult
    func animate(withDuration duration:TimeInterval, delay:TimeInterval, options:UIView.AnimationOptions, animations: @escaping ()->Void, complection:((Bool)->Void)?) -> JAnimationFuture {
        return animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.0, initialSpringVelocity: 0.0, options: [], animations: animations, completion: complection)
    }
    
    @discardableResult
    func animate(withDuration duration:TimeInterval, delay:TimeInterval, usingSpringWithDamping springDamping:CGFloat, initialSpringVelocity springVelocity:CGFloat, options:UIView.AnimationOptions, animations:@escaping ()->Void, completion:((Bool)->Void)?) -> JAnimationFuture {
        let anim = animateAndChain(withDuration: duration, delay: delay, options: options, animations: animations, completion: completion)
        self.springDamping = springDamping
        self.springVelocity = springVelocity
        return anim
    }
    
    @discardableResult
    func animateAndChain(withDuration duration:TimeInterval, delay:TimeInterval, options:UIView.AnimationOptions, animations:@escaping ()->Void, completion:((Bool)->Void)?) -> JAnimationFuture {
        var options = options
        if options.contains(.repeat) {
            loopChain = true
            options.remove(.repeat)
        }
        
        self.duration = duration
        self.delay = delay
        self.options = options
        self.animations = animations
        self.completion = completion
        
        nextAnimation = JAnimationFuture()
        nextAnimation!.previousAnimation = self
        return nextAnimation!
    }
    
    
    func run() {
        if let animations = animations {
            options.insert(.beginFromCurrentState)
            let animationDelay = DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * self.delay)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: animationDelay) {
                if self.springDamping > 0.0 {
                    UIView.animate(withDuration: self.duration, delay: self.delay, options: self.options, animations: animations, completion: self.animationCompleted)
                } else {
                    UIView.animate(withDuration: self.duration, delay: self.delay, usingSpringWithDamping: self.springDamping, initialSpringVelocity: self.springVelocity, options: self.options, animations: animations, completion: self.animationCompleted)
                }
            }
        }
    }
    
    public func cancelAnimationChain(_ completion: (()->Void)? = nil) {
        JAnimationFuture.cancelCompletions[identifier] = completion
        var link = self
        while link.nextAnimation != nil {
            link = link.nextAnimation!
        }
        link.detachFromChain()
    }
    
    private func animationCompleted(_ finished:Bool) {
        self.completion?(finished)
        
        if let cancelComplection = JAnimationFuture.cancelCompletions[identifier] {
            cancelComplection()
            detachFromChain()
            return
        }
        
        if finished && self.loopChain {
            var link = self
            while link.previousAnimation != nil {
                link = link.previousAnimation!
            }
            link.run()
        }
        
        if self.nextAnimation?.animations != nil {
            self.nextAnimation?.run()
        } else {
            detachFromChain()
        }
    }
    
    private func detachFromChain() {
        self.nextAnimation = nil
        if let previous = self.previousAnimation {
            previous.nextAnimation = nil
            previous.detachFromChain()
        } else {
            if let index = JAnimationFuture.animations.firstIndex(where: { (anim) -> Bool in
                return anim == self
            }) {
                JAnimationFuture.animations.remove(at: index)
            }
        }
        self.previousAnimation = nil
    }
    
}

public func == (lhs: JAnimationFuture, rhs: JAnimationFuture) -> Bool {
    return lhs.identifier == rhs.identifier
}
