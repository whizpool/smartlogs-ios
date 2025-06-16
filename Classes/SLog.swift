//
//  SLog.swift
//  SmartLogs
//
//  Created by Whizpool on 13/12/2022.
//

import Foundation
import UIKit
import SSZipArchive
import MessageUI

@MainActor
@objc public class SLog : NSObject {
    
    // ********************* VersionUpdateType ENUMS *********************//
    
//    enum VersionUpdateType {
//        case eNone
//        case eForceUpdate
//        case eOptionalUpdate
//    }
    
    // ********************* Variables *********************//
    
    // Instance of Slog file
    @objc public static let shared = SLog()
    
    //Initializer access level change now
    private override init() {}
    
    // Zip File Password
    var password = ""
    var appStoreID       = ""
    var minorUpdateTitle = ""
    var minorUpdateMsg   = ""
    var forceUpdateTitle = ""
    var forceUpdateMsg   = ""
    
    
    // Background Color
    var alertBackgroundColor : UIColor?
    
    // Title Text, color, font and font size
    var titleText      : String = SLConstants.defaultTitle
    var titleTextColor : UIColor?
    var titleFont      = SLConstants.defaultFontName
    var titleFontSize  = SLConstants.defaultSendBtnFontSize
    
    // line and knob color
    var lineColor : UIColor?
    var knobColor : UIColor?
    
    // present report view
    var hideReportBugView = false
    
    // send button Text, color, font and font size
    var bSendBtnIconHidden = false
    var sendButtonBackgroundColor : UIColor?
    var sendBtnText      : String = SLConstants.defaultSendBtnText
    var SendBtntextColor = UIColor.white
    var sendBtnFont      = SLConstants.defaultFontName
    var sendBtnFontSize  = SLConstants.defaultSendBtnFontSize
    
    var textViewBackgroundColor : UIColor?
    var textViewTextColor : UIColor?
    var textViewFont      = SLConstants.defaultFontName
    var textViewFontSize  = SLConstants.defaultTextViewFontSize
    
    // default cg color
    var defaultColorWhite = #colorLiteral(red: 0.8509805202, green: 0.8509805799, blue: 0.8509805202, alpha: 1)
    var defaultColorBlack = #colorLiteral(red: 0.1098999158, green: 0.1096580997, blue: 0.1184011772, alpha: 1)
    
    // Days after log files deleted
    private var filesDeletionAfterDays:Int = SLConstants.defaultDaysForFileDeletion
    
    // app version name string
    private var versionName:String = ""
    
    // app Build number variable
    private var buildNo:Int64 = 0
    
    // send by default email of developer
    var sendToEmail: String = ""
    
    // Email Subject for mail composer
    var emailSubject = SLConstants.emailSubject
    
    // after combine log file name
    var logFileNameAfterCombine = SLConstants.logFileNameAfterCombine
    
    // Textview Placeholder
    var textViewPlaceHolder = SLConstants.textViewPlaceHolder
    
    // close button icon
    var sendBtnImage : UIImage?
    
    struct AttachmentDetail {
        var fileName = ""
        var mimeType = ""
        var url = ""
    }
    
    var addAttachmentArray = [AttachmentDetail]()
    
    // MARK: - ********************* initilization *********************// -
    
    /// IN INITILLIZATION WE CAN CREATE THE LOG FOLDER
    /// FUNCTION TAKES THE DATE FORMAT FOR THE LOG FILE
    /// FILES ARE CREATED WITH THE NAMES OF THE DATE SO THAT IT IS EASY TO HANDLE FOR SORTING
    /// AND IT CREATE THE DIRECTORY WITH FOLDER NAME
    @objc public func initilization()
    {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        print(path)
        
        if let pathComponent = url.appendingPathComponent(SLConstants.rootDirectoryName)
        {
            _ = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = SLConstants.logFileDateFormat
            
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: filePath)
            {
                let DocumentDirectory = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
                let DirPath = DocumentDirectory.appendingPathComponent(SLConstants.rootDirectoryName)
                do
                {
                    try FileManager.default.createDirectory(atPath: DirPath!.path, withIntermediateDirectories: true, attributes: nil)
                }
                catch let error as NSError
                {
                    print("Unable to create directory \(error.debugDescription)")
                }
            }
        }
        else
        {
            print("FILE PATH NOT AVAILABLE")
        }
        
        // Give Values to versionName and buildNo from functions that is in Utils file
        versionName = SLog.getVersionName()
        buildNo = Int64(SLog.buildNumber)!
        
        // calling delete log file function
        _ = deleteOldLogs(forcefullyDelete: false)
        
        writeLogInFile(message: "")
    }
    
    // MARK: - ********************* Public Functions *********************// -
    
    /// this function is used for writing logs in log file and print on console
    @objc public func summaryLog(text: String?)
    {
        log(text: text, exception: nil, writeInFile: true)
    }
    
    // ****************************************************
    
    /// this function is used to print on console and writing logs in log file ( optional )
    @objc public func detailLog(text: String?, writeIntoFile : Bool)
    {
        log(text: text, exception: nil, writeInFile: writeIntoFile)
    }
    
    // ****************************************************
    
    // Function For checking files are greater then (KEEP_OLD_LOGS_UP_TO_DAYS) or not and call function for deleting files
    // we can also delete the files forcefully by developer end if you want to
    @objc public func deleteOldLogs(forcefullyDelete: Bool) -> Bool
    {
        let fileManager:FileManager = FileManager.default
        let fileList = listFilesFromDocumentsFolder(directoryName: SLConstants.rootDirectoryName)
        let fileCounts = fileList.count
        
        for fileCount in 0..<fileCounts
        {
            if fileManager.fileExists(atPath: fileList[fileCount]) != true
            {
                print("File is \(fileList[fileCount])")
            }
        }
        
        let totalDirectories = fileList.count
        
        /// If there is only one log directory then don't delete anything and return.
        ///  WHY ..... ??
        if (totalDirectories <= 1 && !forcefullyDelete)
        {
            return false
        }
        
        // If total directories are less than 7, then don't delete any thing. But if requested to forcefully delete,
        // then skip this check and proceed forward.
        if (totalDirectories <= filesDeletionAfterDays && !forcefullyDelete)
        {
            return false
        }
        
        // Sort the directories in alphabetical order (in ascending dates)
        let sortArray = fileList.sorted(by: { $0.compare($1) == .orderedAscending })
        
        for (index, file) in sortArray.enumerated()
        {
            // Delete file
            _ = deleteFile(fileName: file)
            
            // After deleting it, check how many drafts are left. If they are less than or equal to 7 then return.
            if (totalDirectories - (index + 1) <= filesDeletionAfterDays)
            {
                break
            }
        }
        
        return true
    }
    
    // ****************************************************
    
    // function to get log days value
    @objc public func setDaysForLog (numberOfDays: Int) {
        filesDeletionAfterDays = numberOfDays
    }
    
    // ****************************************************
    
    // function to get password
    @objc public func setPassword(password:String) {
        self.password = password
    }
    
    // ****************************************************
    
    // function to get the alert title from developer end
    @objc public func setTitle(title:String) {
        self.titleText = title
    }
    
    // ****************************************************
    
    // function to get the send button text from developer end
    @objc public func setSendButtonText (text:String) {
        self.sendBtnText = text
    }
    
    // ****************************************************
    
    // function to get email from the developer end
    @objc public func setEmail (text:String) {
        self.sendToEmail = text
    }
    
    // ****************************************************
    
    // function to get tag value
    @objc public func setSubjectToEmail (sub: String) {
        self.emailSubject = sub
    }
    
    // ****************************************************
    
    // function to set place holder for the text view
    @objc public func setPlaceHolder (text:String) {
        self.textViewPlaceHolder = text
    }
    
    // ****************************************************
    
    // function to set final log file name
    @objc public func setLogFileName (text:String) {
        self.logFileNameAfterCombine = text
    }
    
    // ****************************************************
    
    // function to set close button image
    @objc public func setSendBtnImage (img : UIImage)
    {
        self.sendBtnImage = img
    }
    
    //****************************************************
    
    // setting text field Font
    @objc public func hideSendBtnIcon (bool: Bool)
    {
        self.bSendBtnIconHidden = bool
    }
    
    //****************************************************
    
    // check App Update on appStore
    @objc public func checkAppVersionUpdate (bForceUpdate : Bool, bMinorUpdate : Bool, appStoreID : String, minorUpdateTitle : String? = "", minorUpdateMessage : String? = "", forceUpdateTitle : String? = "", forceUpdateMessage : String? = "" )
    {
        self.appStoreID = appStoreID

        self.minorUpdateTitle = minorUpdateTitle!.isEmpty ? SLConstants.minorUpdateTitle : minorUpdateTitle!
        self.minorUpdateMsg   = minorUpdateMessage!.isEmpty ? SLConstants.minorUpdateMessage : minorUpdateMessage!
        
        self.forceUpdateTitle = forceUpdateTitle!.isEmpty ? SLConstants.forceUpdateTitle : forceUpdateTitle!
        self.forceUpdateMsg   = forceUpdateMessage!.isEmpty ? SLConstants.forceUpdateMessage : forceUpdateMessage!
        
        /// if self.checkForAppUpdateOnStore() is true then check for the app update
        /// and app store app id is required
        if (bForceUpdate || bMinorUpdate) && !appStoreID.isEmpty {
            self.checkForAppUpdateOnStore(bForceUpdate: bForceUpdate, bMinorUpdate: bMinorUpdate)
        }
    }
    
    //****************************************************
    
    // setting text field Font
    @objc public func hideReportDialogue(bool: Bool)
    {
        self.hideReportBugView = bool
    }
    
    // ****************************************************
    
    // setting background color for alert view
    @objc  public func setMainBackgroundColor (backgroundColor : UIColor)
    {
        self.alertBackgroundColor = backgroundColor
    }
    
    // ****************************************************
    
    // setting background color for Text View
    @objc public func setTextViewBackgroundColor (backgroundColor : UIColor)
    {
        self.textViewBackgroundColor = backgroundColor
    }
    
    // ****************************************************
    
    // setting background color for Send Button
    @objc public func setSendButtonBackgroundColor (backgroundColor : UIColor)
    {
        self.sendButtonBackgroundColor = backgroundColor
    }
    
    // ********************* line and knob View *********************
    
    @objc public func setLineColor (color : UIColor)
    {
        self.lineColor = color
    }
    
    //****************************************************
    
    @objc public func setKnobColor (color : UIColor)
    {
        self.knobColor = color
    }
    
    // ********************* Title View *********************
    
    // setting title color
    @objc public func setTitleColor (color : UIColor)
    {
        self.titleTextColor = color
    }
    
    //****************************************************
    
    // setting title Font
    @objc public func setTitleFont (fontName : String)
    {
        self.titleFont = fontName
    }
    
    //****************************************************
    
    // setting title Font Size
    @objc public func setTitleFontSize (fontSize: Int)
    {
        self.titleFontSize = fontSize
    }
    
    //****************************************************
    
    // setting Send button color
    @objc public func setSendBtnTextColor (color : UIColor)
    {
        self.SendBtntextColor = color
    }
    
    //****************************************************
    
    // setting Send button Title Font
    @objc public func setSendBtnFont (fontName : String)
    {
        self.sendBtnFont = fontName
    }
    
    //****************************************************
    
    // setting Send button Title Font Size
    @objc public func setSendBtnFontSize (fontSize: Int)
    {
        self.sendBtnFontSize = fontSize
    }
    
    //****************************************************
    
    // setting background color for TEXT view
    @objc public func setTextViewTextColor (color:UIColor)
    {
        self.textViewTextColor = color
    }
    
    //****************************************************
    
    // setting text field Font
    @objc public func setTextViewFont (fontName : String)
    {
        self.textViewFont = fontName
    }
    
    //****************************************************
    
    // setting text field Font
    @objc public func setTextViewFontSize (fontSize: Int)
    {
        self.textViewFontSize = fontSize
    }
    
    //****************************************************
    
    @objc public func addAttachment (fileName : String = "" , url : String, mimeType : String)
    {
        var tempFileName = fileName
        
        if tempFileName.isEmpty || tempFileName == ""
        {
            let fileUrl : NSString =  url as NSString
            let name : NSString = fileUrl.lastPathComponent as NSString
            tempFileName = name.deletingPathExtension
        }
        
        let attachmentItem = AttachmentDetail(fileName: tempFileName , mimeType: mimeType, url: url)
        addAttachmentArray.append(attachmentItem)
    }
    
    //****************************************************
    
    //SS: remove all attached attachments 
    @objc public func clearAllAttachments()
    {
        if self.addAttachmentArray.count > 0
        {
            self.addAttachmentArray.removeAll()
            print("Attachments removed.")
        }
    }
    
    //****************************************************
    
    // Send email to developer
    @objc public func sendReport(controller : UIViewController)
    {
        if hideReportBugView
        {
            emailComposer(controller: controller)
        }
        else
        {
            let bundle = Bundle(for: SLAlertViewController.self)
            let controllerView = SLAlertViewController(nibName: "SLAlertViewController", bundle: bundle)
            controller.present(controllerView, animated: true, completion: nil)
        }
    }
    
    //****************************************************
    
    /// check the file name using the date formate
    ///  For old data ... because we only check
    private func checkFileNameWRTDateFormate (fileName : String) -> Bool
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = SLConstants.logFileDateFormat
        let dateName = dateFormatter.date(from: fileName)
        
        if dateName == nil {
            return false
        }
        
        return true
    }
    
    // MARK: - ********************* Private Functions *********************// -
    
    // Function For Writing Logs files locally and store them on the phone
    // it checks the path and file if exists it will update the same file
    // other wise it will create the file and store it locally
    private func writeLogInFile(message:String)
    {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        
        //****************************************************
        /// directory name changes and checking old directory if found any data then copied to new directory
        /// deleting the older directory for safer version ... so that no data left behind after coping
        if let oldPathComponent = url.appendingPathComponent(SLConstants.oldRootDirectoryName)
        {
            if oldPathComponent.isDirectory
            {
                print(oldPathComponent)
                let fileList = listFilesFromDocumentsFolder(directoryName: SLConstants.oldRootDirectoryName)
                
                // get the list of the data from older directory
                for fileName in fileList
                {
                    ///checking the files we need with the date formater we used for the file names.
                    ///non other file will be copied
                    if checkFileNameWRTDateFormate(fileName: fileName)
                    {
                        print("date format is correct")
                        let newSmartLogPath = SLog.shared.getRootDirSmartLogsFilesPath()
                        let newSmartLogUrl = URL(string: newSmartLogPath)
                        let newFilePath = newSmartLogUrl!.appendingPathComponent("/\(fileName).txt")
                        
                        /// make sure the file not exist .. if it exist it will not be copied ...
                        if !FileManager.default.fileExists(atPath: newFilePath.path)
                        {
                            do {
                                let olderFiles = oldPathComponent.appendingPathComponent("\(fileName)")
                                try FileManager.default.copyItem(atPath: olderFiles.path, toPath: newFilePath.path)
                                
                                print("\(fileName) file copied")
                            }
                            catch {
                                print(error)
                            }
                        }
                    }
                }
                
                /// when all the files copied logs folder will be deleted
                if FileManager.default.fileExists(atPath: oldPathComponent.path)
                {
                    do {
                        try FileManager.default.removeItem(at: oldPathComponent)
                    }
                    catch {
                        print(error)
                    }
                }
            }
        }
        
        //****************************************************
        
        if let pathComponent = url.appendingPathComponent(SLConstants.rootDirectoryName)
        {
            let date = Date()
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateFormat = SLConstants.logFileDateFormat
            let currentDate = dateFormatter.string(from: date)
            
            let LongDate = getCurrentDate()
            let updatedMessage = "\n\(LongDate)" + " " + "\(message)\n"

            let filename = pathComponent.appendingPathComponent("\(currentDate).txt")
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            
            if fileManager.fileExists(atPath: filePath)
            {
                print("Folder AVAILABLE at path \(filePath)")
                if fileManager.fileExists(atPath: filename.path)
                {
                    print("FILE AVAILABLE")
                    do
                    {
                        let fileUpdater = try FileHandle(forUpdating: filename)
                        // Function which when called will cause all updates to start from end of the file
                        fileUpdater.seekToEndOfFile()
                        
                        // Which lets the caller move editing to any position within the file by supplying an offset
                        fileUpdater.write(updatedMessage.data(using: .utf8)!)
                        
                        // Once we convert our new content to data and write it, we close the file and that’s it!
                        fileUpdater.closeFile()
                        print(updatedMessage)

                    }
                    catch let error as NSError
                    {
                        print("Unable to create directory \(error.debugDescription)")
                    }
                }
                else
                {
                    print("FILE NOT AVAILABLE creating file")
                    /// getting detail of the device and adding into the log file
                    let appVersion = SLog.getVersionName()
                    let manufacture = SLog.getDeviceManufacture()
                    let deviceModel = UIDevice.modelName
                    let OSInstalled = SLog.getOSInfo()
                    var freeSpace:String = ""
                    
                    // calculate free space of device
                    if let Space = SLog.deviceRemainingFreeSpaceInBytes() {
                        freeSpace = Units(bytes: Space).getReadableUnit()
                    }
                    
                    let deviceDetail = "\nappName : \(SLConstants.appName)" + "\nappVersion : \(appVersion)" + "\nmanufacture : \(manufacture)" + "\ndeviceModel : \(deviceModel)" + "\nOSInstalled : \(OSInstalled)" + "\nfreeSpace : \(freeSpace)"
                    
                    let updatedMsgWithDeviceDetail = "\n\(deviceDetail)\n\n\n\(updatedMessage)"
                    
                    
                    do{
                        try updatedMsgWithDeviceDetail.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                        print(updatedMessage)
                    }
                    catch{
                        print(error.localizedDescription)
                    }
                }
            }
            else
            {
                print("Folder NOT AVAILABLE")
                let DocumentDirectory = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
                let DirPath = DocumentDirectory.appendingPathComponent(SLConstants.rootDirectoryName)
                do
                {
                    try FileManager.default.createDirectory(atPath: DirPath!.path, withIntermediateDirectories: true, attributes: nil)
                }
                catch let error as NSError
                {
                    print("Unable to create directory \(error.debugDescription)")
                }
                print("Dir Path = \(DirPath!)")
            }
        }
        else {
            print("FILE PATH NOT AVAILABLE")
        }
    }
    
    // MARK: - ********************* Functions *********************// -
    
    func emailComposer(controller : UIViewController)
    {
        let recieverEmail = SLog.shared.sendToEmail
        guard MFMailComposeViewController.canSendMail()  else {
            //
            SLCommonMethods.showAlertWith(csTitle: SLConstants.alertTitle, csMessage: SLConstants.emailNotConfigureText, viewController: controller)
            return
        }
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients([recieverEmail])
        composer.setSubject(SLog.shared.emailSubject)
        composer.setMessageBody("", isHTML: true)
        
        let logFilePath = SLog.shared.getRootDirSmartLogsFilesPath()
        let logFileUrl = URL(string: logFilePath)
        let logFileZipPath = logFileUrl!.appendingPathComponent("/\(SLConstants.logZipFolder)")
        
//        let jsonFilePath = SLog.shared.getRootDirJsonFilesPath()
//        let jsonFileUrl = URL(string: jsonFilePath)
        
        do {
            
            SLCommonMethods.createPasswordProtectedZipLogFile(at: logFileZipPath.path, name: self.logFileNameAfterCombine, composer: composer, controller: controller)
            SLCommonMethods.createJsonFile(composer: composer, controller: controller)
            
            //SLCommonMethods.createPasswordProtectedZipJsonFile(at: jsonFileUrl!.path, composer: composer, controller: controller)
            SLCommonMethods.checkAttachedFiles(composer: composer)
            controller.present(composer, animated: true)
        }
    }
    
    //****************************************************
    
    /// func will combine the all the log files which are being created every day into one final log file
    /// when we report the bug of wants the log fiels it will combine all the log files
    /// then zip it and post it at the given email address
    func combineLogFiles(completion: (String, Error?) -> ())
    {
        // Delete Zip Folder
        _ = SLog.shared.deleteFile(fileName: SLConstants.logZipFolder)

        let fileManager = FileManager.default
        var files = [String]()
        files.removeAll()
        var fileCombine = URL(string: "")
        var finalLogString = ""
        
        // getting files from Slog Function
        files = SLog.shared.listFilesFromDocumentsFolder(directoryName: SLConstants.rootDirectoryName)

        // arrange Files in orderedAscending
        files = files.sorted(by: { $0.compare($1) == .orderedAscending })
        for file in files
        {
            //if you get access to the directory
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            {
                //prepare file url
                let fileURL = dir.appendingPathComponent("\(SLConstants.rootDirectoryName)/")
                let DirPath = fileURL.appendingPathComponent(SLConstants.logZipFolder)

                do
                {
                    try FileManager.default.createDirectory(atPath: DirPath.path, withIntermediateDirectories: true, attributes: nil)
                }
                catch let error as NSError
                {
                    print("Unable to create directory \(error.debugDescription)")
                }

                print("Dir Path = \(DirPath)")

                let newZipDirURL = fileURL.appendingPathComponent(file)
                fileCombine = DirPath.appendingPathComponent(self.logFileNameAfterCombine)

                do {
                    let fileStartingString = "\n\n ******************************* \(file) *******************************\n"
                    
                    let data = try String(contentsOf: newZipDirURL, encoding: .utf8)
                    finalLogString = finalLogString + fileStartingString + data
                }
                catch {
                    print(error.localizedDescription)
                    completion("", error)
                }
            }
        }
        
        print ("finalLogFileString : \n\n\(finalLogString)")
        
        if (fileCombine != nil)
        {
            if fileManager.fileExists(atPath: fileCombine!.path)
            {
                // File Available
                if let fileUpdater = try? FileHandle(forUpdating: fileCombine!)
                {
                    // Function which when called will cause all updates to start from end of the file
                    fileUpdater.seekToEndOfFile()

                    // Which lets the caller move editing to any position within the file by supplying an offset
                    fileUpdater.write(finalLogString.data(using: .utf8)!)

                    // Once we convert our new content to data and write it, we close the file and that’s it!
                    fileUpdater.closeFile()

                    completion(fileCombine!.path, nil)
                }
            }
            else
            {
                if (FileManager.default.createFile(atPath: fileCombine!.path, contents: nil, attributes: nil))
                {
                    print("File created successfully.")
                    do{
                        try finalLogString.write(to: fileCombine!, atomically: true, encoding: String.Encoding.utf8)

                        let pathURL = fileCombine! // URL
                        let pathString = pathURL.path // String

                        completion(pathString, nil)
                    }
                    catch {
                        print(error.localizedDescription)
                        completion("", error)
                    }
                }
            }
        }
    }
    
    // ****************************************************
    
    /// Fuction make Json file for ios it will get the phone details
    /// and store and zip it for the developer
    ///
    func makeJsonFile(completion: (String, Error?) -> ())
    {
        // -> URL
        // create empty dict
        var myDict = [String: String]()
        
        // calling function of manufacture,deviceModel,OSInstalled,appVersion and set that functions value in dict
        let manufacture = SLog.getDeviceManufacture()
        let deviceModel = UIDevice.modelName
        let OSInstalled = SLog.getOSInfo()
        let appVersion = SLog.getVersionName()
        var freeSpace:String = ""
        
        // calculate free space of device
        if let Space = SLog.deviceRemainingFreeSpaceInBytes()
        {
            print("free space: \(Space)")
            print(Units(bytes: Space).getReadableUnit())
            freeSpace = Units(bytes: Space).getReadableUnit()
        }
        else
        {
            print("failed")
        }
        
        // Add Values in Dict
        myDict = ["appName":SLConstants.appName, "appVersion":appVersion,"OSInstalled":OSInstalled,"deviceModel":deviceModel,"manufacture":manufacture,"freeSpace":freeSpace]
        
        do {
            try saveJsonFileInDirectory(jsonObject: myDict, toFilename: SLConstants.deviceInfo, completion: { filePath, saveJsonErr in
                
                if saveJsonErr != nil
                {
                    completion(filePath, saveJsonErr)
                }
                else
                {
                    completion(filePath, nil)
                }
            })
        }
        catch {
            print(error.localizedDescription)
            completion("",error)
        }
    }
    
    // ****************************************************
    
    // create json file in directory with specific information of device
    func saveJsonFileInDirectory(jsonObject: Any, toFilename filename: String, completion: (String, Error?) -> ()) throws
    {
        let fm = FileManager.default
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
//        let jsonErr : Error
        
        if let url = urls.first
        {
            var rootDirectory = url.appendingPathComponent("\(SLConstants.rootDirectoryName)/")
            let deviceInfoJsonName = rootDirectory.appendingPathComponent(filename)
            rootDirectory = deviceInfoJsonName.appendingPathExtension("json")
            let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
            
            if FileManager.default.fileExists(atPath: rootDirectory.path)
            {
                print("FILE EXIST")
                
                do {
                    try data.write(to: rootDirectory, options: [.atomicWrite])
                    completion(rootDirectory.path, nil)
                }
                catch {
                    print(error.localizedDescription)
                    completion("", error)
                }
            }
            else
            {
                if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                {
                    //prepare file url
                    let DirPath = dir.appendingPathComponent(SLConstants.rootDirectoryName)
                    
                    do
                    {
                        try FileManager.default.createDirectory(atPath: DirPath.path, withIntermediateDirectories: true, attributes: nil)
                    }
                    catch let error as NSError
                    {
                        print("Unable to create directory \(error.debugDescription)")
                    }
                    
                    print("Dir Path = \(DirPath)")
                }
                
                
                print("File created successfully.")
                do {
                    try data.write(to: rootDirectory, options: [.atomicWrite])
                    completion(rootDirectory.path, nil)
                }
                catch {
                    print(error.localizedDescription)
                    completion("", error)
                }
            }
        }
        else
        {
            completion("", nil)
        }
    }
    
    // ****************************************************
    
    // this function is call from above log function
    func log(text: String?, exception: NSException?, writeInFile : Bool)
    {
        var textToLog:String = ""
        if (text == nil || text!.isEmpty) {
            textToLog = "Null Message"
        }
        else{
            textToLog = text!
        }
        
        if (exception == nil){
            print("Log: \(textToLog)")
            
        }
        else{
            print("Log:Log: \(textToLog). Exception: \(String(describing: exception))")
        }
        
        /// this function is call for writing logs in log file
        if writeInFile
        {
            writeLogInFile(message: text!)
        }
    }
    
    // ****************************************************
    
    // function for getting App Version Number
    class func getVersionName() -> String {
        //First get the nsObject by defining as an optional anyObject
        if let nsObject = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        {
            let version = nsObject
            return version
        }
        
        return ""
    }
    
    // ****************************************************
    
    // function for getting App Build Number
    static var buildNumber:String
    {
        if let buildNum = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String)
        {
            return "\(buildNum)"
        }
        return ""
    }
    
    // ****************************************************
    
    // function for getting Os Version
    class func getOSInfo()->String {
        let os = ProcessInfo.processInfo.operatingSystemVersion
        return String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
    }
    
    // ****************************************************
    
    // function for getting device manufacture
    class func getDeviceManufacture()->String {
        let os = "iPhone"
        return os
    }
    
    // ****************************************************
    
    // Function For getting logs files from Directory and return Files List
    func listFilesFromDocumentsFolder(directoryName: String) -> [String]
    {
        var fileListLogFile = [String]()
        fileListLogFile.removeAll()
        let dirs = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
        if dirs != []
        {
            let dir = dirs[0]
            let fileList = try! FileManager.default.contentsOfDirectory(atPath: dir + "/\(directoryName)")
            
            for list in fileList
            {
                if list == ".DS_Store" || list == SLConstants.logZipFolder || list == SLConstants.deviceInfo
                {
                    continue
                }
                else
                {
                    fileListLogFile.append(list)
                }
            }
            return fileListLogFile
        }
        else
        {
            fileListLogFile = [""]
            return fileListLogFile
        }
    }
    
    // ****************************************************
    
    // Function For Deleting Files From Directory when we can give this function file name
    func deleteFile(fileName : String) -> Bool {
        let fileManager = FileManager.default
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("\(SLConstants.rootDirectoryName)" + "/" + fileName)
        {
            do {
                try fileManager.removeItem(at: pathComponent)
                print("File deleted")
                return true
            }
            catch {
                print(error.localizedDescription)
            }
        }
        return false
    }
    
    // ****************************************************
    
    func logException(text: String?, map: [String:Any], exception: NSException?)
    {
        log(text: text, exception: exception, writeInFile: true)
    }
    
    // ****************************************************
    
    // Function For Getting Current Date
    func getCurrentDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd kk:mm:ss.SSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let DateTime = formatter.string(from: date)
        let strOfDateTime = String(DateTime)
        return strOfDateTime
    }
    
    // ****************************************************
    
    // Function For Getting root Directory Smart logs folder path
    func getRootDirSmartLogsFilesPath() -> String {
        var PATH = ""
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        
        if let pathComponent = url.appendingPathComponent(SLConstants.rootDirectoryName)
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = SLConstants.logFileDateFormat
            
            let filePath = pathComponent.path
            PATH = filePath
            return PATH
        }
        return PATH
    }
    
    // ****************************************************
    
    // Function For Getting root Directory folder path
    func getRootDirJsonFilesPath() -> String {
        var PATH = ""
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        
        if let pathComponent = url.appendingPathComponent(SLConstants.rootDirectoryName)
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = SLConstants.logFileDateFormat
            
            let filePath = pathComponent.path
            PATH = filePath
            return PATH
        }
        return PATH
    }
    
    // ****************************************************
    
    // converting Bytes into Mb,Gb etc
    class func deviceRemainingFreeSpaceInBytes() -> Int64? {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        guard
            let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: documentDirectory),
            let freeSize = systemAttributes[.systemFreeSize] as? NSNumber
        else {
            // something failed
            return nil
        }
        return freeSize.int64Value
    }
    
    // ****************************************************
    
    /// this function will check the main app version from the apple store
    /// and compare it with the current version and show the dialouge
   
    func checkForAppUpdateOnStore(bForceUpdate : Bool, bMinorUpdate : Bool)
    {
        if let bundleId = Bundle.main.infoDictionary!["CFBundleIdentifier"] as? String
        {
            let urlString = "https://itunes.apple.com/lookup?bundleId=\(bundleId)"
            
            if let url = URL(string: urlString)
            {
                let request = NSMutableURLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData,timeoutInterval: Double.infinity)
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue("en", forHTTPHeaderField: "Accept-Language")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "GET"
                
                let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                    DispatchQueue.main.async {
                        guard let data = data else {
                            print(String(describing: error))
                            return
                        }
                        
                        if let responseV = response as? HTTPURLResponse
                        {
                            print("resp: \(responseV)")
                        }
                        
                        do {
                            if let responseJsonV = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                            {
                                //                            DispatchQueue.main.async {
                                if let jsonData = responseJsonV["results"] as? [[String: Any]]
                                {
                                    //                                DispatchQueue.main.async {
                                    if let versionString = jsonData.first?["version"] as? String {
                                        
                                        ///split string
                                        let versionStringComponent = versionString.split(separator: ".").compactMap { Int($0) }
                                        let currentVersionString = (Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String)!
                                        
                                        ///split string
                                        let currentVersionComponent = currentVersionString.split(separator: ".").compactMap { Int($0) }
                                        
                                        ///check if its major version change
                                        if currentVersionComponent.count > 0, versionStringComponent.count > 0, (versionStringComponent[0] > currentVersionComponent[0]) && bForceUpdate
                                        {
                                            /// force update
                                            /// force and minor update giveing manually due to we need to move to the app's play store
                                            /// only for force update .. not for minor update
                                            
                                            SLCommonMethods.showVersionCheckAlert (csTitle: self.forceUpdateTitle, csMessage: self.forceUpdateMsg, appStoreID: self.appStoreID, bForceUpdate: true, bMinorUpdate: false)
                                        }
                                        else if currentVersionComponent.count > 1, versionStringComponent.count > 1, (versionStringComponent[1] > currentVersionComponent[1]) && bMinorUpdate
                                        {
                                            /// minor update
                                            /// force and minor update giveing manually due to we need to move to the app's play store
                                            /// only for force update .. not for minor update
                                            
                                            SLCommonMethods.showVersionCheckAlert (csTitle: self.minorUpdateTitle, csMessage: self.minorUpdateMsg, appStoreID: self.appStoreID, bForceUpdate: false, bMinorUpdate: true)
                                        }
                                    }
                                }
                                //                            }
                            }
                        }
                        catch let myJSONError {
                            print(myJSONError)
                        }
                    }
                }
                
                task.resume()
            }
        }
    }
    
    // ****************************************************
    
    /// shows the alert for the update cases on the basis of enums
    /// optional update show alert once in a day
    /// forceupdate show the alert every time when user comes to the main app
//    func showAlertForUpdateCase(_ updateType:VersionUpdateType)
//    {
//        var bNeedToShow = false
//        if updateType == .eForceUpdate
//        {
//            bNeedToShow = true
//        }
//        else if updateType == .eOptionalUpdate
//        {
//            //check if alert displayed for today
//            let userDef = UserDefaults.standard
//            if let lastChecked = userDef.object(forKey: "Last_checked") as? Date
//            {
//                if !Calendar.current.isDateInToday(lastChecked)
//                {
//                    bNeedToShow = true
//                }
//
//                //show alert
//                userDef.set(Date(), forKey: "Last_checked")
//                userDef.synchronize()
//            }
//            else
//            {
//                bNeedToShow = true
//            }
//        }
//
//        if bNeedToShow
//        {
//            SLCommonMethods.showVersionCheckAlert (csTitle: "App Update Required", csMessage: "Please update your app, this major update may include new feature and fixes which helps in better performance.", appStoreID: self.appStoreID) /// handle bneedToShow
//        }
//    }
}

// MARK: - ********************* Extensions *********************// -

// getting Device model Extension
public extension UIDevice {
    
    static let modelName: String = {
        //
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        // ****************************************************
        
        func mapToDevice(identifier: String) -> String
        { // swiftlint:disable:this cyclomatic_complexity
            
#if os(iOS)
            switch identifier {
            case "iPod5,1":                                       return "iPod touch (5th generation)"
            case "iPod7,1":                                       return "iPod touch (6th generation)"
            case "iPod9,1":                                       return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":           return "iPhone 4"
            case "iPhone4,1":                                     return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                        return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                        return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                        return "iPhone 5s"
            case "iPhone7,2":                                     return "iPhone 6"
            case "iPhone7,1":                                     return "iPhone 6 Plus"
            case "iPhone8,1":                                     return "iPhone 6s"
            case "iPhone8,2":                                     return "iPhone 6s Plus"
            case "iPhone8,4":                                     return "iPhone SE"
            case "iPhone9,1", "iPhone9,3":                        return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                        return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                      return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                      return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                      return "iPhone X"
            case "iPhone11,2":                                    return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                      return "iPhone XS Max"
            case "iPhone11,8":                                    return "iPhone XR"
            case "iPhone12,1":                                    return "iPhone 11"
            case "iPhone12,3":                                    return "iPhone 11 Pro"
            case "iPhone12,5":                                    return "iPhone 11 Pro Max"
            case "iPhone12,8":                                    return "iPhone SE (2nd generation)"
            case "iPhone13,1":                                    return "iPhone 12 mini"
            case "iPhone13,2":                                    return "iPhone 12"
            case "iPhone13,3":                                    return "iPhone 12 Pro"
            case "iPhone13,4":                                    return "iPhone 12 Pro Max"
            case "iPhone14,4":                                    return "iPhone 13 mini"
            case "iPhone14,5":                                    return "iPhone 13"
            case "iPhone14,2":                                    return "iPhone 13 Pro"
            case "iPhone14,3":                                    return "iPhone 13 Pro Max"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":      return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":                 return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":                 return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                          return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                            return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                          return "iPad (7th generation)"
            case "iPad11,6", "iPad11,7":                          return "iPad (8th generation)"
            case "iPad12,1", "iPad12,2":                          return "iPad (9th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":                 return "iPad Air"
            case "iPad5,3", "iPad5,4":                            return "iPad Air 2"
            case "iPad11,3", "iPad11,4":                          return "iPad Air (3rd generation)"
            case "iPad13,1", "iPad13,2":                          return "iPad Air (4th generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":                 return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":                 return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":                 return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                            return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                          return "iPad mini (5th generation)"
            case "iPad14,1", "iPad14,2":                          return "iPad mini (6th generation)"
            case "iPad6,3", "iPad6,4":                            return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                            return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":      return "iPad Pro (11-inch) (1st generation)"
            case "iPad8,9", "iPad8,10":                           return "iPad Pro (11-inch) (2nd generation)"
            case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":  return "iPad Pro (11-inch) (3rd generation)"
            case "iPad6,7", "iPad6,8":                            return "iPad Pro (12.9-inch) (1st generation)"
            case "iPad7,1", "iPad7,2":                            return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":      return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                          return "iPad Pro (12.9-inch) (4th generation)"
            case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":return "iPad Pro (12.9-inch) (5th generation)"
            case "AppleTV5,3":                                    return "Apple TV"
            case "AppleTV6,2":                                    return "Apple TV 4K"
            case "AudioAccessory1,1":                             return "HomePod"
            case "AudioAccessory5,1":                             return "HomePod mini"
            case "i386", "x86_64", "arm64":                                return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                              return identifier
            }
#elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
#endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
}

// ****************************************************

// Struct For Calculating Free Space in Device
public struct Units {
    
    public let bytes: Int64
    
    public var kilobytes: Double {
        return Double(bytes) / 1_024
    }
    
    public var megabytes: Double {
        return kilobytes / 1_024
    }
    
    public var gigabytes: Double {
        return megabytes / 1_024
    }
    
    public init(bytes: Int64) {
        self.bytes = bytes
    }
    
    public func getReadableUnit() -> String {
        
        switch bytes {
        case 0..<1_024:
            return "\(bytes) bytes"
        case 1_024..<(1_024 * 1_024):
            return "\(String(format: "%.2f", kilobytes)) kb"
        case 1_024..<(1_024 * 1_024 * 1_024):
            return "\(String(format: "%.2f", megabytes)) mb"
        case (1_024 * 1_024 * 1_024)...Int64.max:
            return "\(String(format: "%.2f", gigabytes)) gb"
        default:
            return "\(bytes) bytes"
        }
    }
}

// ********************* Extensions *********************//

// Extension for mail composing delegate
extension SLog: @preconcurrency MFMailComposeViewControllerDelegate
{
    public func mailComposeController (_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if let _ = error
        {
            controller.dismiss(animated: true, completion: nil)
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
        controller.dismiss(animated: true, completion: nil)
    }
}

extension URL {
    var isDirectory: Bool {
       (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
