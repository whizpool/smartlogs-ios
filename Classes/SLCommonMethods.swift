//
//  SLCommonMethods.swift
//  SmartLogs
//
//  Created by Himy Mughal on 15/12/2022.
//

import UIKit
import Foundation
import MessageUI
import SSZipArchive

class SLCommonMethods
{
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
    static func screenWidth () -> CGFloat{
        return UIScreen.main.bounds.width
    }

    // ****************************************
    
    // Screen height.
    static func screenHeight () -> CGFloat{
        return UIScreen.main.bounds.height
    }
    
    // ****************************************
    
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
    static func createPasswordProtectedZipLogFile(at logfilePath: String, composer viewController: MFMailComposeViewController, controller : UIViewController)
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
                SLog.shared.makeJsonFile { jsonfilePath, jsonErr in
                    //
                    let contentsPath = logfilePath
                    
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
                        if FileManager.default.fileExists(atPath: contentsPath)
                        {
                            let createZipPath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(SLog.shared.finalLogFileNameAfterCombine).zip").path
                            
                            if SLog.shared.password.isEmpty {
                                isZipped = SSZipArchive.createZipFile(atPath: createZipPath, withContentsOfDirectory: contentsPath)
                            }
                            else{
                                isZipped = SSZipArchive.createZipFile(atPath: createZipPath, withContentsOfDirectory: contentsPath, keepParentDirectory: true, withPassword: SLog.shared.password)
                            }
                            
                            if isZipped {
                                var data = NSData(contentsOfFile: createZipPath) as Data?
                                if let data = data
                                {
                                    viewController.addAttachmentData(data, mimeType: "application/zip", fileName: ("\(SLog.shared.finalLogFileNameAfterCombine).zip"))
                                }
                                data = nil
                            }
                        }
                    }
                }
            }
        }
    }
}
