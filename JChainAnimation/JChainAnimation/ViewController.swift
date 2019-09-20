//
//  ViewController.swift
//  JChainAnimation
//
//  Created by jams on 2019/9/20.
//  Copyright © 2019 jams. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var redSquare: UIView!
    private var blueSquare: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        redSquare = UIView.init()
        redSquare.backgroundColor = UIColor.red
        redSquare.frame = CGRect(x: 50, y: 150, width: 100, height: 100)
        view.addSubview(redSquare)
        
        blueSquare = UIView.init()
        blueSquare.backgroundColor = UIColor.blue
        blueSquare.frame = CGRect(x: (view.bounds.size.width - 100 - 50), y: 150, width: 100, height:100)
        view.addSubview(blueSquare)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.jAnimate()
        }
    }

    func animate() {
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.33, initialSpringVelocity: 0.00, options: [], animations: {
            self.redSquare.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
                                        .concatenating(CGAffineTransform(scaleX: 1.5, y: 1.5))
            
            self.blueSquare.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(CGFloat(-Double.pi/4), 0.0, 0.0, 1.0),
                                                CATransform3DMakeScale(1.33, 1.33, 1.33))
            self.blueSquare.layer.cornerRadius = 50.0
        }) { (finished) in
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.33, initialSpringVelocity: 0.0, options: [], animations: {
                
                self.redSquare.transform = CGAffineTransform.identity
                self.blueSquare.layer.transform = CATransform3DIdentity
                self.blueSquare.layer.cornerRadius = 0.0
                
            }, completion: nil)
        }
    }
    
    func jAnimate() {
        UIView.animateAndChain(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.33, initialVelocity: 0.00, options: [], animations: {
            
            self.redSquare.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
                .concatenating(CGAffineTransform(scaleX: 1.5, y: 1.5))
            
            self.blueSquare.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(CGFloat(-Double.pi/4), 0.0, 0.0, 1.0),
                                                                  CATransform3DMakeScale(1.33, 1.33, 1.33))
            self.blueSquare.layer.cornerRadius = 50.0
            
        }, completion: nil).animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.33, initialSpringVelocity: 0.0, options: .repeat, animations: {
            
            self.redSquare.transform = CGAffineTransform.identity
            self.blueSquare.layer.transform = CATransform3DIdentity
            self.blueSquare.layer.cornerRadius = 0.0
            
        }, completion: nil);
    }
    
}

