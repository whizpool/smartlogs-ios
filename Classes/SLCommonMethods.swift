//
//  SLCommonMethods.swift
//  SmartLogs
//
//  Created by Whizpool on 15/12/2022.
//

import UIKit
import Foundation
import MessageUI
#if canImport(ZipArchive)
import ZipArchive
#elseif canImport(SSZipArchive)
import SSZipArchive
#else
#error("Neither ZipArchive nor SSZipArchive is available.")
#endif

class SLCommonMethods
{
    @MainActor
    static func showAlertWith(csTitle:String, csMessage:String, viewController:UIViewController)
    {
        let alertVC = UIAlertController(title: csTitle, message: csMessage, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: SLConstants.ok, style: .default, handler: { action in
            //
            
        }))
        
        DispatchQueue.main.async {
            viewController.present(alertVC, animated: true, completion: nil)
        }
    }
    
    /********************************************************/
    @MainActor
    static func showVersionCheckAlert(csTitle:String, csMessage:String, appStoreID:String, bForceUpdate:Bool, bMinorUpdate:Bool)
    {
        var topWindow: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
        topWindow?.rootViewController = UIViewController()
        topWindow?.windowLevel = UIWindow.Level.alert + 1
        
        var actionTitle = "OK"
        
        if bForceUpdate && !bMinorUpdate {
            actionTitle = "Go To App Store"
        }

        let alert = UIAlertController(title: csTitle, message: csMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .cancel) { _ in
            // continue your work

            // important to hide the window after work completed.
            // this also keeps a reference to the window until the action is invoked.
            topWindow?.isHidden = true // if you want to hide the topwindow then use this
            topWindow = nil // if you want to hide the topwindow then use this
            
            /// if force update true then open the app in app store other wise dismiss
            if bForceUpdate && !bMinorUpdate {
                //// this will open the app in play store ...
                if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appStoreID)"), UIApplication.shared.canOpenURL(url)
                {
                    UIApplication.shared.open(url)
                }
            }
            
         })

        // show alert
        topWindow?.makeKeyAndVisible()
        topWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    /********************************************************/
    @MainActor
    static func showAlertWithHandler(viewContoller : UIViewController , title : String , message : String, leftButtonText : String? , rightButtonText :String? , leftButtonActionHandler: (()->())?, rightButtonActionHandler: (()->())? )
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if  rightButtonText != nil && rightButtonText != ""
        {
            alert.addAction(UIAlertAction(title: rightButtonText, style: .default, handler: { (alertAction) in
               rightButtonActionHandler?()
            }))
        }
        
        if  leftButtonText != nil && leftButtonText != ""
        {
            alert.addAction(UIAlertAction(title: leftButtonText, style: .cancel, handler: { (alertAction) in
                leftButtonActionHandler?()
            }))
        }
        
        DispatchQueue.main.async {
            viewContoller.present(alert, animated: true, completion: nil)
        }
    }
    
    // ****************************************
    
    // screen width
    @MainActor
    static func screenWidth () -> CGFloat{
        return UIScreen.main.bounds.width
    }

    // ****************************************
    
    // Screen height.
    @MainActor
    static func screenHeight () -> CGFloat{
        return UIScreen.main.bounds.height
    }
    
    // ****************************************
    
    @MainActor
    static func checkAttachedFiles(composer viewController: MFMailComposeViewController)
    {
        for file in SLog.shared.addAttachmentArray
        {
            if let fileData = NSData(contentsOfFile: file.url)
            {
                viewController.addAttachmentData(fileData as Data, mimeType: file.mimeType, fileName: file.fileName)
            }
        }
    }
    
    //****************************************************
    
    /// func will combine the all the log files which are being created every day into one final log file
    /// when we report the bug of wants the log fiels it will combine all the log files
    /// then zip it and post it at the given email address
    /// Function create zip and create password on it
    @MainActor
    static func createPasswordProtectedZipLogFile(at logfilePath: String, name fileName: String, composer viewController: MFMailComposeViewController, controller : UIViewController)
    {
        var isZipped:Bool = false
        // calling combine all files into one file
        SLog.shared.combineLogFiles { filePath, combineFileErr in
            //
            if combineFileErr != nil
            {
                SLCommonMethods.showAlertWithHandler(viewContoller: controller, title: SLConstants.alertTitle, message: combineFileErr!.localizedDescription, leftButtonText: SLConstants.ok, rightButtonText: "") {
                    return
                } rightButtonActionHandler: {
                    //
                }
            }
            else
            {
                /// we are not using the
                let contentsPath = logfilePath

                // create a json file and call a function of makeJsonFile
                if FileManager.default.fileExists(atPath: contentsPath)
                {
                    let createZipPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(fileName).zip").path

                    if SLog.shared.password.isEmpty {
                        isZipped = SSZipArchive.createZipFile(atPath: createZipPath, withContentsOfDirectory: contentsPath)
                    }
                    else
                    {
                        isZipped = SSZipArchive.createZipFile(atPath: createZipPath, withContentsOfDirectory: contentsPath, keepParentDirectory: true, withPassword: SLog.shared.password)
                    }

                    if isZipped {
                        var data = NSData(contentsOfFile: createZipPath) as Data?
                        if let data = data
                        {
                            viewController.addAttachmentData(data, mimeType: "application/zip", fileName: ("\(fileName).zip"))
                        }
                        data = nil
                    }
                }
            }
        }
    }

    //****************************************************
    @MainActor
    static func createJsonFile(composer viewController: MFMailComposeViewController, controller : UIViewController)
    {
        SLog.shared.makeJsonFile { jsonfilePath, jsonErr in
            //
            if jsonErr != nil
            {
                SLCommonMethods.showAlertWithHandler(viewContoller: controller, title: SLConstants.alertTitle, message: jsonErr!.localizedDescription, leftButtonText: SLConstants.ok, rightButtonText: "") {
                    return
                } rightButtonActionHandler: {
                    //
                }
            }
            else
            {
                // create a json file and call a function of makeJsonFile
                if FileManager.default.fileExists(atPath: jsonfilePath)
                {
                    var data = NSData(contentsOfFile: jsonfilePath) as Data?
                    if let data = data
                    {
                        viewController.addAttachmentData(data, mimeType: "application/json", fileName: ("\(SLConstants.deviceInfo).json"))
                    }
                    data = nil
                }
            }
        }
    }

    //****************************************************
    @MainActor
    static func createPasswordProtectedZipJsonFile(at logfilePath: String, composer viewController: MFMailComposeViewController, controller : UIViewController)
    {
        var isZipped:Bool = false

        SLog.shared.makeJsonFile { jsonfilePath, jsonErr in
            //
            if jsonErr != nil
            {
                SLCommonMethods.showAlertWithHandler(viewContoller: controller, title: SLConstants.alertTitle, message: jsonErr!.localizedDescription, leftButtonText: SLConstants.ok, rightButtonText: "") {
                    return
                } rightButtonActionHandler: {
                    //
                }
            }
            else
            {
                /// we are not using the
                let contentsPath = logfilePath

                // create a json file and call a function of makeJsonFile
                if FileManager.default.fileExists(atPath: contentsPath)
                {
                    let createZipPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(SLConstants.deviceInfo).zip").path

                    if SLog.shared.password.isEmpty {
                        isZipped = SSZipArchive.createZipFile(atPath: createZipPath, withContentsOfDirectory: contentsPath)
                    }
                    else
                    {
                        isZipped = SSZipArchive.createZipFile(atPath: createZipPath, withContentsOfDirectory: contentsPath, keepParentDirectory: true, withPassword: SLog.shared.password)
                    }

                    if isZipped {
                        var data = NSData(contentsOfFile: createZipPath) as Data?
                        if let data = data
                        {
                            viewController.addAttachmentData(data, mimeType: "application/zip", fileName: ("\(SLConstants.deviceInfo).zip"))
                        }
                        data = nil
                    }
                }
            }
        }
    }
}
