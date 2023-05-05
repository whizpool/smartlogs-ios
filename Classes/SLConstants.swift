//
//  SLConstants.swift
//  SmartLogs
//
//  Created by Whizpool on 13/12/2022.
//

import Foundation

public class SLConstants
{
    static let defaultFontName = "Helvetica Neue Medium"
    static let defaultTitle = "Report a bug"
    static let defaultSendBtnText = "Send Report"
    static let defaultSendBtnFontSize = 17
    static let defaultTextViewFontSize = 14
    
    static let defaultDaysForFileDeletion = 7
    static let oldRootDirectoryName = "Logs"
    static let rootDirectoryName = "SmartLogs"
    
    static let logZipFolder = "Logs"
    static let logFileDateFormat = "yyyy-MM-dd"
    static let logFileNameAfterCombine = "SmartLog"
    static let deviceInfo = "deviceInfo"
    
    static let forceUpdateTitle = "App Update Required"
    static let minorUpdateTitle = "App Update Available"
    
    static let forceUpdateMessage = "Please update the app, the new version includes features and critical bug fixes that will improve performance and usability"
    static let minorUpdateMessage = "Please update the app, the new version includes bug fixes that will improve performance and usability."
    
    
    static let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? ""
    static let emailSubject = "Bug report: " + appName
    
    static let textViewPlaceHolder = "Write here about your bug detail"
    
    static let ok = "Ok"
    static let alertTitle = "Alert"
    static let bugDetailMissingText = "Atleast 10 characters required for bug report"
    static let emailNotConfigureText = "Email not configure"
    
    static let knobRadius = 3.0
    static let defaultRadius = 12.0
    
    static let dismissReportViewObserver = NSNotification.Name("dismissReportViewObserver")
    
}
