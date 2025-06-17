//
//  SLAlertViewController.swift
//  SmartLogs
//
//  Created by Whizpool on 13/12/2022.
//

import UIKit
#if canImport(ZipArchive)
import ZipArchive
#elseif canImport(SSZipArchive)
import SSZipArchive
#else
#error("Neither ZipArchive nor SSZipArchive is available.")
#endif
import Foundation
import MessageUI

class SLAlertViewController: UIViewController {
    
    
    // ********************* Outlets *********************//
    // MARK: - View controller Outlets -
    
    // Tittle Label Outlet
    @IBOutlet weak var titleLbl: UILabel!
    // Send Button outlet
    @IBOutlet weak var sendBtnImage : UIImageView!
    @IBOutlet weak var sendBtnLbl: UILabel!
    @IBOutlet weak var sendBtnImgView: UIView!
    @IBOutlet weak var sendBtnView: UIView!

    // main view outlet
    @IBOutlet weak var mainAlertView: UIView!
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var mainTextFieldViewHeight : NSLayoutConstraint!

    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var knobView: UIView!
    
    // Bugs TextView Outlet
    @IBOutlet weak var bugsTextview: SLGrowingTextView!
    
    
    var bDarkMode = false
    
    //MARK: - // ********************* ViewDidLoad *********************// -
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let customTextView = SLGrowingTextView(frame: textFieldView.bounds)
        customTextView.translatesAutoresizingMaskIntoConstraints = false
        textFieldView.addSubview(customTextView)
        
        // Add constraints to fit it in the container
        NSLayoutConstraint.activate([
            customTextView.topAnchor.constraint(equalTo: textFieldView.topAnchor),
            customTextView.bottomAnchor.constraint(equalTo: textFieldView.bottomAnchor),
            customTextView.leadingAnchor.constraint(equalTo: textFieldView.leadingAnchor),
            customTextView.trailingAnchor.constraint(equalTo: textFieldView.trailingAnchor)
        ])
        
        self.bugsTextview = customTextView
        
        // Textview Editing function
        textviewEditing()
        
        self.bDarkMode = self.checkDarkMode()
        
        
    }
    
    // MARK: - // ********************* ACTION MEHTODS *********************// -
    
    @IBAction func sendBtnAction(_ sender: UIButton)
    {
        /// Send Button Action where we can check textview is empty or check text is equal to placeholder when both condition are ture we can show alert message Bug Detail is Missing if condition is false then we can proceed further
        
        if bugsTextview.text.isEmpty || bugsTextview.text == SLog.shared.textViewPlaceHolder || bugsTextview.text.count <= 10
        {
            // show alert when textview is empty
            SLCommonMethods.showAlertWith(csTitle: SLConstants.alertTitle, csMessage: SLConstants.bugDetailMissingText, viewController: self)
        }
        else
        {
            let recieverEmail = SLog.shared.sendToEmail
            guard MFMailComposeViewController.canSendMail()  else {
                //
                SLCommonMethods.showAlertWith(csTitle: SLConstants.alertTitle, csMessage: SLConstants.emailNotConfigureText, viewController: self)
                return
            }
            
            let composer = MFMailComposeViewController()
            composer.mailComposeDelegate = self
            composer.setToRecipients([recieverEmail])
            composer.setSubject(SLog.shared.emailSubject)
            composer.setMessageBody(bugsTextview.text, isHTML: true)
            
            let logFilePath = SLog.shared.getRootDirSmartLogsFilesPath()
            let logFileUrl = URL(string: logFilePath)
            let logFileZipPath = logFileUrl!.appendingPathComponent("/\(SLConstants.logZipFolder)")
            
//            let jsonFilePath = SLog.shared.getRootDirJsonFilesPath()
//            let jsonFileUrl = URL(string: jsonFilePath)
            
            do {
                SLCommonMethods.createPasswordProtectedZipLogFile(at: logFileZipPath.path, name: SLog.shared.logFileNameAfterCombine, composer: composer, controller: self)
                SLCommonMethods.createJsonFile(composer: composer, controller: self)
                
                SLCommonMethods.checkAttachedFiles(composer: composer)
                self.present(composer, animated: true)
            }
        }
    }
    
    // MARK: - // ********************* Methods *********************// -
    
    /// this fuction executed right after when phone enables or disables the dark mode \
    /// upone that we have to update the uicolors of views
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?)
    {
        self.bDarkMode = self.checkDarkMode()
        
        // textFieldView backgroundColor color handling along with dark mode
        if SLog.shared.textViewBackgroundColor != nil
        {
            self.textFieldView.backgroundColor = SLog.shared.textViewBackgroundColor
        }
        
        
        // setup main alert view background color
        if SLog.shared.alertBackgroundColor != nil
        {
            self.mainAlertView.backgroundColor = SLog.shared.alertBackgroundColor
        }
        
        
        // bugsTextview text color handling along with dark mode
        self.bugsTextview.textColor = SLog.shared.defaultColorBlack
        if SLog.shared.textViewTextColor != nil
        {
            self.bugsTextview.textColor = SLog.shared.textViewTextColor
        }
        else if self.bDarkMode
        {
            self.bugsTextview.textColor = SLog.shared.defaultColorWhite
        }
        
        
        // title color handling along with dark mode
        if SLog.shared.titleTextColor != nil
        {
            self.titleLbl.textColor = SLog.shared.titleTextColor
        }
    }
}

// ********************* Extensions *********************//

// Extension for mail composing delegate
extension SLAlertViewController:@preconcurrency MFMailComposeViewControllerDelegate
{
    public func mailComposeController (_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if let _ = error
        {
            controller.dismiss(animated: true) {
                self.dismiss(animated: true)
            }
        }
        switch result {
        case .cancelled:
            print("cancel")
        case .saved:
            print("saved")
        case .sent:
            print("sent")
        case .failed:
            print("failed")
        default:
            print("default")
        }
        controller.dismiss(animated: true) {
            self.dismiss(animated: true)
        }
    }
}


// Extension for Textview Editing or Delegate
extension SLAlertViewController: UITextViewDelegate {
    
    // setting textview, buttons colors and set app name to tittle label
    func textviewEditing() {
        
//        DispatchQueue.main.async {
            //
            self.bugsTextview.delegate = self
            self.bugsTextview.layer.cornerRadius = SLConstants.defaultRadius
//            self.bugsTextview.maxHeight = (UIScreen.main.bounds.size.height / 2) - 140
//            self.bugsTextview.minHeight = (UIScreen.main.bounds.size.height / 2) - 140
            self.bugsTextview.trimWhiteSpaceWhenEndEditing = true
            self.bugsTextview.placeholder = SLog.shared.textViewPlaceHolder
            self.bugsTextview.placeholderColor = UIColor(white: 0.8, alpha: 1.0)
//            self.bugsTextview.backgroundColor = SLog.shared.textViewBackgroundColor
            self.bugsTextview.textColor = SLog.shared.textViewTextColor
            self.bugsTextview.font = UIFont(name: SLog.shared.textViewFont, size: CGFloat(SLog.shared.textViewFontSize))
            self.bugsTextview.translatesAutoresizingMaskIntoConstraints = false
            self.bugsTextview.becomeFirstResponder()

            
            /// set the height of the text view on the alert view
            self.mainTextFieldViewHeight.constant = (UIScreen.main.bounds.size.height * 0.39)
            
            
            // main view corner radius
            self.textFieldView.layer.cornerRadius = SLConstants.defaultRadius
            
            if SLog.shared.textViewBackgroundColor != nil
            {
                self.textFieldView.backgroundColor = SLog.shared.textViewBackgroundColor
            }
            
            self.mainAlertView.layer.cornerRadius = SLConstants.defaultRadius
//            self.mainAlertView.backgroundColor = SLog.shared.alertBackgroundColor
//            self.titile_lbl.textColor = SLog.shared.textColor
            
            
            // set the image of the send Btn
            self.sendBtnImgView.isHidden = SLog.shared.bSendBtnIconHidden
            
            if !SLog.shared.bSendBtnIconHidden && SLog.shared.sendBtnImage != nil// icon hidden
            {
                self.sendBtnImage.image = SLog.shared.sendBtnImage
            }
            
            // set line and knob color
            if SLog.shared.knobColor != nil
            {
                self.lineView.backgroundColor = SLog.shared.lineColor
            }
            
            
            self.knobView.layer.cornerRadius = SLConstants.knobRadius
            if SLog.shared.lineColor != nil
            {
                self.knobView.backgroundColor = SLog.shared.knobColor
            }
            
            
            // Title text color , size and font
            self.titleLbl.textColor = SLog.shared.titleTextColor
            self.titleLbl.font = UIFont(name: SLog.shared.titleFont, size: CGFloat(SLog.shared.titleFontSize))
            
            
            // Send Button corner radius, text and text color
            self.sendBtnView.layer.cornerRadius = SLConstants.defaultRadius
            
            if SLog.shared.sendButtonBackgroundColor != nil
            {
                self.sendBtnView.backgroundColor = SLog.shared.sendButtonBackgroundColor
            }
            
            // send button text color , size and font
            self.sendBtnLbl.textColor = SLog.shared.SendBtntextColor
            self.sendBtnLbl.font = UIFont(name: SLog.shared.sendBtnFont, size: CGFloat(SLog.shared.sendBtnFontSize))
            
            
            // set appName to tittle label
            if SLog.shared.titleText.isEmpty
            {
                let appName = Bundle.main.infoDictionary!["CFBundleName"] as! String
                self.titleLbl.text = appName
            }
            else
            {
                self.titleLbl.text = SLog.shared.titleText
            }
            
            // set Send button Lable
            if SLog.shared.sendBtnText.isEmpty
            {
                self.sendBtnLbl.text = SLConstants.defaultSendBtnText
            }
            else
            {
                self.sendBtnLbl.text = SLog.shared.sendBtnText
            }
//        }
    }
    
    //****************************************************
    
    // when textview is Editing
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == SLog.shared.textViewPlaceHolder{
            textView.text = ""
        }
    }
    
    //****************************************************
    
    // when textview text is change
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if text == "\n"{
//            textView.resignFirstResponder()
//        }
        return true
    }
    
    //****************************************************
    
    // when textview text is end
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = SLog.shared.textViewPlaceHolder
        }
    }
    
    //****************************************************
    
    func checkDarkMode() -> Bool
    {
        if #available(iOS 12.0, *) {
            if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyle.dark)
            {
                return true
            }
            else
            {
                return false
            }
        }
        
        return false
    }
}
