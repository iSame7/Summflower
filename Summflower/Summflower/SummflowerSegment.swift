//
//  FloraSegment.swift
//  Flora
//
//  Created by Sameh Mabrouk on 12/24/14.
//  Copyright (c) 2014 SMApps. All rights reserved.
//

/*
//SummflowerSegment act as a UITableviewCell for this control. It follows the same configuration as a tableview delegate
*/

import UIKit

class SummflowerSegment: UIButton {

    
    var backgroundImage:UIImageView = UIImageView()
 
    
    convenience override init() {
        self.init(frame: CGRectMake(0, 0, SegmentWidth, SegmentHeight))
    }
    
    func initWithImage(image:UIImage) -> AnyObject{
        
        self.alpha = SegmentAlpha
        self.backgroundColor = UIColor.clearColor()
        self.autoresizingMask = UIViewAutoresizing.FlexibleWidth | .FlexibleHeight
        self.backgroundImage.image = image
        self.backgroundImage.frame = self.bounds
        self.addSubview(self.backgroundImage)
        
        //setup shadows
        self.layer.shadowColor = SegmentShadowColor.CGColor
        self.layer.shadowOffset = SegmentShadowOffset
        self.layer.shadowOpacity = SegmentShadowOpacity
        self.layer.shadowRadius = SegmentShadowRadis
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = SegmentRasterizationScale
        
        return self
    }
    
    
    func rotationWithDuration(duration:NSTimeInterval, angle:Float, completion: ((Bool) -> Void)?){
        // Repeat a quarter rotation as many times as needed to complete the full rotation
        var sign:Float = angle > 0 ? 1 : -1
        let numberRepeats:Float = floorf(fabsf(angle) / Float( M_PI_2))
        let angelabs:CGFloat = CGFloat(fabs(angle))
        let quarterDuration:Float = Float(duration * M_PI_2) / Float(angelabs)
        
        let lastRotation = angle - sign * numberRepeats * Float(M_PI_2)
        let lastDuration:Float = Float( duration) - quarterDuration * numberRepeats
        
        self.lastRotationWithDuration(NSTimeInterval(lastDuration), rotation: CGFloat( lastRotation))
        
        self.quarterSpinningBlock(NSTimeInterval(quarterDuration), duration: NSInteger(lastDuration), rotation: NSInteger(lastRotation), numberRepeats: NSInteger(numberRepeats))
        
        return completion!(true)
    }
    
    func quarterSpinningBlock(quarterDuration:NSTimeInterval, duration:NSInteger, rotation:NSInteger, numberRepeats:NSInteger){

        if numberRepeats>0 {
            
            UIView.animateWithDuration(quarterDuration, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState | UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                self.transform = CGAffineTransformRotate(self.transform, CGFloat(M_PI_2))
                }) { (Bool) -> Void in
                   
                    if numberRepeats > 0 {
                        
                        self.quarterSpinningBlock(quarterDuration, duration: duration, rotation: rotation, numberRepeats: numberRepeats - 1 )
                    }
                    else{
                        
                        self.lastRotationWithDuration(NSTimeInterval(duration), rotation: CGFloat(rotation))
                        return
                    }

                    
            }
        }
        else{
        
            self.lastRotationWithDuration(NSTimeInterval(duration), rotation: CGFloat(rotation))
            

        }
        
        
    }
    
    func lastRotationWithDuration(duration:NSTimeInterval, rotation:CGFloat){
    
        UIView.animateWithDuration(duration, delay: 0.0, options: .BeginFromCurrentState | .CurveEaseOut, animations: { () -> Void in
            self.transform = CGAffineTransformRotate(self.transform, rotation);
            }, completion: nil)

    }
    
    
}