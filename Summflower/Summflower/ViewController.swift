//
//  ViewController.swift
//  Flora
//
//  Created by Sameh Mabrouk on 12/24/14.
//  Copyright (c) 2014 SMApps. All rights reserved.
//

import UIKit
import MessageUI
import Social

let TwitterSegmentIndex = 0
let FavoriteSegmentIndex = 1
let EmailSegmentIndex = 2
let FacebookSegmentIndex = 3




class ViewController: UIViewController,SummflowerViewDataSource,SummflowerViewDelegate, MFMailComposeViewControllerDelegate {
    
    var summflowerData:NSMutableArray!
    var summflowerControl:SummflowerViewController!
    
    var sharedImg:UIImage = UIImage(named: "Summflower.png")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Initialize the Summflower data
        var plistPath:NSString = NSBundle.mainBundle().pathForResource("SegmentData", ofType: "plist")!
        
        // Build the array from the plist
        summflowerData = NSMutableArray(contentsOfFile: plistPath)!
        
        // Configure the Flora control and add to view controllers view.
        summflowerControl = SummflowerViewController(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        summflowerControl.setDelegateAndDataSource(self, delegate: self)
        
        self.view.setSummflowerViewController(summflowerControl)
        self.view.addSubview(summflowerControl)
    }
    
    func floraView(floraView: AnyObject, numberOfRowsInSection section: Int) -> Int{
        
        println("numberOfRowsInSection \(self.summflowerData.count)")
        
        return self.summflowerData.count
        
    }
    func floraView(floraView: AnyObject, itemForRowAtIndexPath indexPath: NSIndexPath) -> SummflowerSegment{
        
        var dicForSegment:NSDictionary = self.summflowerData.objectAtIndex(indexPath.row) as NSDictionary
        var imageName: NSString = dicForSegment.objectForKey("image")! as NSString
        
        var floraSegment:SummflowerSegment = SummflowerSegment()
        floraSegment.initWithImage(UIImage(named: imageName)!)
        
        return floraSegment
    }
    
    // Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
    func floraView(tableView: AnyObject, willSelectItemAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?{
        
        println("willSelectItemAtIndexPath")
        return indexPath
    }
    
    // Called after the user changes the selection.
    func floraView(tableView: AnyObject, didSelectItemAtIndexPath indexPath: NSIndexPath){
        
        println("didSelectItemAtIndexPath \(indexPath.row)")
        
        if indexPath.row == FacebookSegmentIndex{
            
            self.shareOnSocialMedia(FacebookSegmentIndex)
        }
        else if indexPath.row == TwitterSegmentIndex{
            self.shareOnSocialMedia(TwitterSegmentIndex)
        }
        else if indexPath.row == FavoriteSegmentIndex{
            
        }
        else if indexPath.row == EmailSegmentIndex{
            
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        }
    }
    
    
    func floraView(tableView: AnyObject, didFinishExpandingAtPoint point: CGPoint){
        
        NSLog("Finished expanding at point (%f, %f)", point.x, point.y);
        
    }
    
    func floraView(tableView: AnyObject, didFinishExpandingSegment segment: SummflowerSegment){
        println("didFinishExpandingSegment")
        
    }
    
    func floraView(tableView: AnyObject, didFinishCollapsingSegment segment: SummflowerSegment){
        
        println("didFinishCollapsingSegment")
    }
    
    
    func floraView(tableView: AnyObject, didFinishCollapsingAtPoint point: CGPoint){
        
        NSLog("Finished Collapsing at point (%f, %f)", point.x, point.y);
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - shareFB
    func shareOnSocialMedia(serviceType:Int){
        
        var SocialMedia :SLComposeViewController!
        
        if serviceType == FacebookSegmentIndex{
            SocialMedia  = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        }
        else if serviceType == TwitterSegmentIndex{
            SocialMedia  = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        }
        
        
        if(SLComposeViewController.isAvailableForServiceType(SocialMedia.serviceType))
        {
            
            SocialMedia.completionHandler = {
                result -> Void in
                
                var getResult = result as SLComposeViewControllerResult;
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            self.presentViewController(SocialMedia, animated: true, completion: nil)
            SocialMedia.setInitialText("Check out this cool iOS Swift UI control! \n @summly @yahoo")
            SocialMedia.addURL(NSURL(string: "https://github.com/iSame7/Summflower"))
            SocialMedia.addImage(sharedImg)
        }
        else{
            
            
            let actionSheetController:UIAlertController = UIAlertController(title: "Service Not Supported", message: "Go to device settings and configure the service", preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            actionSheetController.addAction(cancelAction)
            self.presentViewController(actionSheetController, animated: true, completion: nil)
            
        }
        
        
        
    }
    
    // MARK: - email configuration
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients([""])
        mailComposerVC.setSubject("Check out Summflower control on Github")
        mailComposerVC.setMessageBody("Check out this cool iOS Swift UI control! \n https://github.com/iSame7/Summflower", isHTML: false)
        mailComposerVC.addAttachmentData(UIImageJPEGRepresentation(sharedImg, 1), mimeType: "image/png", fileName: "screenshot.png")
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}

