//
//  FloraView.swift
//  Flora
//
//  Created by Sameh Mabrouk on 12/26/14.
//  Copyright (c) 2014 SMApps. All rights reserved.
//

import Foundation
import UIKit

// this protocol represents the data model object of Summflower.
@objc protocol SummflowerViewDataSource{
    
    optional func floraView(floraView: AnyObject, numberOfRowsInSection section: Int) -> Int
    optional func floraView(floraView: AnyObject, itemForRowAtIndexPath indexPath: NSIndexPath) -> SummflowerSegment
}

// this represents the display and behaviour of the segments.
@objc protocol SummflowerViewDelegate{

    // Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
    optional func floraView(tableView: AnyObject, willSelectItemAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    
    // Called after the user changes the selection.
    optional func floraView(tableView: AnyObject, didSelectItemAtIndexPath indexPath: NSIndexPath)
    
    //Called after the animations have completed
    optional func floraView(tableView: AnyObject, didFinishExpandingAtPoint point: CGPoint)
    optional func floraView(tableView: AnyObject, didFinishCollapsingAtPoint point: CGPoint)
    
    optional func floraView(tableView: AnyObject, didFinishExpandingSegment segment: SummflowerSegment)
    optional func floraView(tableView: AnyObject, didFinishCollapsingSegment segment: SummflowerSegment)
}