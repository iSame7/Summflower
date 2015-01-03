//
//  FloraController.swift
//  Flora
//
//  Created by Sameh Mabrouk on 12/24/14.
//  Copyright (c) 2014 SMApps. All rights reserved.
//

import UIKit

//Segment Constants Properties.
let SegmentAlpha:CGFloat = 0.96
let SegmentShadowColor = UIColor.darkGrayColor()
let SegmentShadowOffset = CGSizeMake(0, 3)
let SegmentShadowOpacity:Float = 0.6
let SegmentShadowRadis:CGFloat = 4
let SegmentWidth:CGFloat = 60.0
let SegmentHeight:CGFloat = 80.0

//Animation Constants.
let AnimationSegmentSpread:CGFloat = 1.003  //parameter for determining how crowded segments are with respect to each other
let AnimationSegmentMinScale:CGFloat = 0.001 //Scale of the item at its smallest (i.e 0.01 is 1/100th its original size
let AnimationGrowDuration:NSTimeInterval = 0.3
let AnimationSegmentMaxScale:CGFloat = 1000 //Scale of the item at its largest (relative to on kAnimationPetalMinScale)
let AnimationSegmentDelay:CGFloat = 0.1 //The amount of time between animating each segment

let AnimationFanOutDegrees:Double = 360.0 //Amount  for the control to fan out 360 = fully fanned out, 180 = half fanned out
let AnimationRotateDuration:NSTimeInterval = 0.3


//Control Layout Constants.
let SegmentRasterizationScale:CGFloat = 5.0
let LongPressDuration:CFTimeInterval = 1.0 //The length of time before a touch is registered and the control appears on the parent view
let DefaultLeftMargin = SegmentHeight * AnimationSegmentSpread//Amount of space to reserve the left to ensure that the control doesnt get drawn off screen
let DefaultRightMargin = SegmentHeight * AnimationSegmentSpread//Amount of space to reserve the right to ensure that the control doesnt get drawn off screen
let DefaultTopMargin = SegmentHeight * AnimationSegmentSpread//Amount of space to reserve the top to ensure that the control doesnt get drawn off screen
let DefaultBottomtMargin = SegmentHeight * AnimationSegmentSpread//Amount of space to reserve the bottom to ensure that the control doesnt get drawn off screen
let DefaultHeight = 2*SegmentHeight*AnimationSegmentSpread
let DefaultWidth = DefaultHeight

/*
https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Extensions.html
Extensions add new functionality to an existing class, structure, or enumeration type. This includes the ability to extend types for which you do not have access to the original source code (known as retroactive modeling). Extensions are similar to categories in Objective-C. (Unlike Objective-C categories, Swift extensions do not have names.)
*/
extension UIView{
    
    func setSummflowerViewController(summflowerObj:SummflowerViewController){
        summflowerObj.monitorView = self
        
        //Register for touch events on long press
        var gestureRecognizer:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: summflowerObj, action: "didUserFiredLongPress:")
        
        //Set the default time length for the touch to fire
        gestureRecognizer.minimumPressDuration = LongPressDuration
        
        //Add recognizer to the view
        self.addGestureRecognizer(gestureRecognizer)
    }
}

// Creates a Summflower view with the correct dimensions and autoresizing, setting the datasource and delegate to self.
@objc class SummflowerViewController: UIView, SummflowerViewDataSource, SummflowerViewDelegate {
    
    
    override init(frame: CGRect) {
        println("init FloraViewController")
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //An array contains the FloraSegment objects.
    var segments:NSArray = []
    
    //view that recieve the touch events.
    var monitorView:UIView!
    
    //datasource
    var dataSource:SummflowerViewDataSource!
    //delegate
    var delegate:SummflowerViewDelegate!
    
    func setDelegateAndDataSource(dataSource:SummflowerViewDataSource, delegate:SummflowerViewDelegate){
        
        self.transform = CGAffineTransformMakeRotation(( 0.0 ) / 180.0 * CGFloat(M_PI))
        //initialize the data source and delegate variables.
        self.dataSource = dataSource
        self.delegate = delegate
        //Call the reloadItems to populate the items array from the data source
        self.reloadSummFlowerItems()
        
        self.hidden = true
    }
    
    func reloadSummFlowerItems(){
        var totalItems:NSInteger = self.dataSource.floraView!(self, numberOfRowsInSection: 0)
        
        var items:NSMutableArray = NSMutableArray()
        
        //Iterate over each item and add it to the items array
        for var index = 0; index < totalItems; ++index{
            
            var currentIndexPath:NSIndexPath = NSIndexPath(forRow:index, inSection: 0)
            var item:SummflowerSegment = self.dataSource.floraView!(self, itemForRowAtIndexPath: currentIndexPath)
            
            //Assign selector to control.
            item.addTarget(self, action: "didSelectSegment:", forControlEvents: UIControlEvents.TouchUpInside)
            
            items.addObject(item)
        }
        self.segments = items
    }
    
    func didSelectSegment(segment:SummflowerSegment){
        
        var indexPath:NSIndexPath = self.indexPathForItem(segment)
        
        //Check if the user wants to specify a different index path for selection
        indexPath = self.delegate.floraView!(self, willSelectItemAtIndexPath: indexPath)!
        
        self.collapseItems()
        
        //Fire delegate callback informing of selection
        self.delegate.floraView!(self, didSelectItemAtIndexPath: indexPath)
    }
    
    func indexPathForItem(item:SummflowerSegment) -> NSIndexPath{
        
        let rowNumber:NSInteger = self.segments.indexOfObject(item)
        return NSIndexPath(forRow: rowNumber, inSection: 0)
    }
    
    //grow flower e.g. expand flower items at user pressed point.
    func growFlowerAtPoint(point:CGPoint){
        
        var delay:CGFloat =  0.0
        
        for segment in self.segments{
            
            var indexPath:NSIndexPath = self.indexPathForItem(segment as SummflowerSegment)
            self.expandItemAtIndexPath(indexPath, atOrigin: point, withDelay: NSTimeInterval(delay))
            delay += AnimationSegmentDelay
            self.addSubview(segment as UIView)
        }
    }
    
    //collapse flower segment after user select segment.
    func collapseItems(){
        
        for segment in self.segments{
            
            var indexPath:NSIndexPath = self.indexPathForItem(segment as SummflowerSegment)
            
            self.collapseItemAtIndexPath(indexPath, withDelay: 0)
        }
    }
    
    func expandRotateAnimationForSegment(segment:SummflowerSegment){
        var indexPath:NSIndexPath = self.indexPathForItem(segment)
        
        //  3. Rotate clockwise to the position allowing for variable numbers of items equal spacing between each item
        var totalItemCount:NSInteger = self.segments.count
        var row:NSInteger = indexPath.row
        
        var rotationFactor:CGFloat = CGFloat(totalItemCount - row) / CGFloat(totalItemCount)
        
        var rotationAngle:CGFloat = 2 * CGFloat(M_PI) * rotationFactor
        
        segment.rotationWithDuration(AnimationRotateDuration, angle:Float(rotationAngle)) { (Bool) -> Void in
            
            self.delegate.floraView!(self, didFinishExpandingSegment: segment)
            
            if indexPath.row == totalItemCount - 1{
                
                self.delegate.floraView!(self, didFinishExpandingAtPoint: self.center)
                
            }
        }
        
        
    }
    
    func shrinkAnimationForSegment(segment:SummflowerSegment, withDelay delay:NSTimeInterval){
        
        var indexPath:NSIndexPath = self.indexPathForItem(segment)
        var totalItemCount:Int = self.segments.count
        
        UIView.animateWithDuration(AnimationGrowDuration, delay: delay, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            
            segment.layer.transform = CATransform3DScale(segment.layer.transform, AnimationSegmentMinScale, AnimationSegmentMinScale, 1)
            
            }) { (Bool) -> Void in
                self.delegate.floraView!(self, didFinishCollapsingSegment: segment)
                
                if indexPath.row == totalItemCount - 1{
                    
                    self.delegate.floraView!(self, didFinishCollapsingAtPoint: self.center)
                    
                }
                if self.indexPathForItem(segment).row == 0{
                    
                    self.hidden=true
                }
                
        }
        
    }
    
    func expandItemAtIndexPath(indexPath:NSIndexPath, atOrigin origin:CGPoint, withDelay delay:NSTimeInterval){
        
        //First, set the view to be not hidden so that the animation will appear on screen
        self.center = origin
        self.hidden=false
        
        var item:SummflowerSegment = self.segments.objectAtIndex(indexPath.row) as SummflowerSegment
        
        //Get the center point of the control to determine where the animation should originate from
        
        //  1. Grow from size (0,0) and move upwards as specified by the constants above
        
        item.layer.transform = CATransform3DMakeScale(AnimationSegmentMinScale, AnimationSegmentMinScale, 1)
        item.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0)
        
        //  2. Set the anchor point to X = width/2 and Y = height + y animated offset from 1.
        
        var anchorPoint:CGPoint = CGPointMake(0.5, AnimationSegmentSpread)
        item.layer.anchorPoint=anchorPoint
        
        UIView.animateWithDuration(AnimationGrowDuration, delay: delay, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            item.layer.transform = CATransform3DScale(item.layer.transform, AnimationSegmentMaxScale, AnimationSegmentMaxScale, 1)
            
            }) { (Bool) -> Void in
                var totalItemCount:NSInteger = self.segments.count
                if self.indexPathForItem(item).row == totalItemCount - 1{
                    
                    for segment in self.segments{
                        
                        self.expandRotateAnimationForSegment(segment as SummflowerSegment)
                    }
                }
        }
        
    }
    
    func collapseItemAtIndexPath(indexPath:NSIndexPath , withDelay delay:NSTimeInterval){
        
        //reversing what is done in Expanding Segments
        var item:SummflowerSegment = self.segments.objectAtIndex(indexPath.row) as SummflowerSegment
        var totalItemCount:NSInteger = self.segments.count
        var row:Int = indexPath.row
        
        var rotationFactor:CGFloat = CGFloat(totalItemCount - row) / CGFloat(totalItemCount)
        
        var rotationAngle:CGFloat = 2 * CGFloat( M_PI) * rotationFactor
        
        
        UIView.animateWithDuration(AnimationRotateDuration, delay: delay, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            
            var angel:CGFloat =  CGFloat(2*M_PI) - rotationAngle
            
            item.layer.transform = CATransform3DRotate(item.layer.transform, CGFloat(angel), 0.0, 0.0, 1.0)
            
            }) { (Bool) -> Void in
                var totalItemCount:NSInteger = self.segments.count
                if self.indexPathForItem(item).row == totalItemCount - 1{
                    
                    var delay:CGFloat = 0
                    delay += AnimationSegmentDelay
                    
                    for segment in self.segments.reverseObjectEnumerator().allObjects{
                        
                        self.shrinkAnimationForSegment(segment as SummflowerSegment, withDelay: NSTimeInterval(delay))
                        delay += AnimationSegmentDelay
                        
                    }
                }
        }
    }
    
    func didUserFiredLongPress(recognizer:UILongPressGestureRecognizer){
        
        if recognizer.state != UIGestureRecognizerState.Ended && self.hidden {
            
            //Get the coordinates of the press.
            var touchCenter:CGPoint = recognizer.locationInView(self.monitorView)
            
            //Determine where the point should be.
            var touchX:CGFloat = touchCenter.x
            var touchY:CGFloat = touchCenter.y
            
            //Handle the left and right margins.
            if touchX < DefaultLeftMargin{
                touchX = DefaultLeftMargin
            }
            else if touchX > self.monitorView.frame.size.width - DefaultRightMargin{
                
                touchX = self.monitorView.frame.size.width - DefaultRightMargin
            }
            
            //Handle the top and bottom margins.
            if touchY < DefaultTopMargin{
                
                touchY = DefaultTopMargin
            }
            else if touchY > self.monitorView.frame.size.height - DefaultBottomtMargin{
                
                touchY = self.monitorView.frame.size.height - DefaultBottomtMargin
            }
            
            self.growFlowerAtPoint(CGPointMake(touchX, touchY))
        }
    }
    
    
}

