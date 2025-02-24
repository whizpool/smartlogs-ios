//
//  SLViewController.swift
//  SmartLogs
//
//  Created by Whizpool on 12/13/2022.
//  Copyright (c) 2022 Whizpool. All rights reserved.
//

import UIKit
import SmartLogs
import MessageUI

class SLViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        SLog.shared.initilization()
        
        
        SLog.shared.checkAppVersionUpdate(bForceUpdate: true, bMinorUpdate: true, appStoreID: "1492988563")

        
        

        
        
        
        
//        //function Textview Editing Calls
//        SLog.shared.setPassword(password: "QWERTY")
//
//        // set Title
//        SLog.shared.setTitle(title: "Map App")
//
//        // set days
//        SLog.shared.setDaysForLog(numberOfDays: 2)
//
//        // set email
//        SLog.shared.setEmail(text: "")
//
//        // set email Subject
//        SLog.shared.setSubjectToEmail(sub: "BUG REPORT ")
//
//        // set place holder for the text views
//        SLog.shared.setPlaceHolder(text: "Enter Your Bug Detail")
//
//        // set final log file name which is going to be emailed
//        SLog.shared.setLogFileName(text: "finalLog")
//
//        // set alert view background color
//        SLog.shared.setMainBackgroundColor(backgroundColor: .yellow)
//
//        // set send btn icon
//        SLog.shared.setSendBtnImage(img: UIImage(named: "testImg")!)
//
//        // hide / unhide send btn icon
//        SLog.shared.hideSendBtnIcon(bool: true)
//
//
//        //set nobe and line color
//        SLog.shared.setKnobColor(color: .red)
//        SLog.shared.setLineColor(color: .green)
//
//
//        // set text view text, font name, font size, and text color
//        SLog.shared.setTextViewBackgroundColor(backgroundColor: .brown)
//        SLog.shared.setTextViewTextColor(color: .green)
//        SLog.shared.setTextViewFont(fontName: "Marker Felt Thin")
//        SLog.shared.setTextViewFontSize(fontSize: 17)
//
//
//        // set title text, font name, font size and text color
//        SLog.shared.setTitle(title: "Title Here")
//        SLog.shared.setTitleFont(fontName: "Marker Felt Thin")
//        SLog.shared.setTitleFontSize(fontSize: 22)
//        SLog.shared.setTitleColor(color: .purple)
//
//        
//        // set send button view text, font name, font size, and text color
//        SLog.shared.setSendButtonText(text: "Send Button Text")
//        SLog.shared.setSendBtnFont(fontName: "Marker Felt Thin")
//        SLog.shared.setSendBtnFontSize(fontSize: 30)
//        SLog.shared.setSendBtnTextColor(color: .green)
//        SLog.shared.setSendButtonBackgroundColor(backgroundColor: .red)
    }
    
    // ****************************************************
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ****************************************************
    
    @IBAction func showLogBtn(_ sender : UIButton)
    {
        SLog.shared.summaryLog(text: "show log btn pressed")
    }
    
    // ****************************************************
    
    @IBAction func addAttachmentsBtn(_ sender : UIButton)
    {
        if let filePath = Bundle.main.path(forResource: "Twitter", ofType: "png")
        {
            SLog.shared.addAttachment(url: filePath, mimeType: "image/png")
        }
    }
    // ****************************************************
    
    @IBAction func clearAllBtn(_ sender : UIButton)
    {
        SLog.shared.clearAllAttachments()
    }
    
    // ****************************************************
    
    @IBAction func sendLOgBtn(_ sender : UIButton)
    {
//        SLog.shared.summaryLog(text: "Summary Log Here")
//        SLog.shared.detailLog(text: "detail log here", writeIntoFile: true)
        
        SLog.shared.hideReportDialogue(bool: false)
        SLog.shared.sendReport(controller: self)
    }
}

