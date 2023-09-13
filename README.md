# SmartLogs

[![Version](https://img.shields.io/cocoapods/v/SmartLogs.svg?style=flat)](https://cocoapods.org/pods/SmartLogs)
[![License](https://img.shields.io/cocoapods/l/SmartLogs.svg?style=flat)](https://cocoapods.org/pods/SmartLogs)
[![Platform](https://img.shields.io/cocoapods/p/SmartLogs.svg?style=flat)](https://cocoapods.org/pods/SmartLogs)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Features

 1) create new log file everyday with current date name.
 2) compress zip and make password on it (optional).
 3) Delete old files depending on the number of days provided to by developer
 4) Display an alert which take textual input from user about the issue / bug they are facing
 5) Hide the report alert view if you dont want the end user comment
 6) The theme of alert view can be customizable
 7) The send-to email should be provided by developer
 8) A JSON file should also get attached with following information:
        -> Device manufacturer
        -> Device model
        -> OS installed on device
        -> Currently running app version
        -> Free storage space available


## Installation

SmartLogs is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SmartLogs'
```


 ## SamrtLogs Example

```swift
 // let's import the logging API package
import SmartLogs

 // initilization Sdk in 
SLog.shared.initilization()

 // we're now ready to use it
 // summary log is used to print in console and it will also write the log into file 
SLog.shared.summaryLog(text: "summary log will be saved in final log file")

 // detail log is used to print in console and it will also write the log into final log file (optional)
SLog.shared.detailLog(text: "detail log will be saved in final log file (optional)", writeIntoFile: false)
```

# Output Final Log File Contains

```
2022-03-02 15:12:19.507 summary log will be saved in final log file

```


## Swift Implementation

## Import SDK 

    // import the SDK first 
    import SmartLogs

    
## Initization 

        // call initilization in the app delegate 
        // initilization sdk
        
        SLog.shared.initilization()
        
        
## Write Logs to file 

        // Summary logs must write log into the files 
        SLog.shared.summaryLog(text: "summary log here")
        
        // Detail logs are optional to write in the file
        SLog.shared.detailLog(text: "detail log here", writeIntoFile: true)


## Setup log file
        
        // Set zip archive Password
        SLog.shared.setPassword(password: "Password12345")
        
        // set days for Logs Deletion
        SLog.shared.setDaysForLog(numberOfDays: 7)
        
        // delete logs files forcefully
        SLog.shared.deleteOldLogs(forcefullyDelete: true)
        
        // Attachment Files     
        SLog.shared.addAttachment(fileName: "icon", url: filePath, mimeType: "image/png")
        
        // set email
        SLog.shared.setEmail(text: "abc@xyz.com")
        
        // set email Subject
        SLog.shared.setSubjectToEmail(sub: "BUG REPORT ")
        
        // setup check App version and show forced and minor alert for update. 
        SLog.shared.checkAppVersionUpdate(bForceUpdate: true, bMinorUpdate: true, appStoreID: "1234567")

## Report Alert (end user UI)
        
        // set Title
        SLog.shared.setTitle(title: "Map App")
        
        // set main alert view background color
        SLog.shared.setMainBackgroundColor(backgroundColor: .yellow)
        
        // set place holder for the text views
        SLog.shared.setPlaceHolder(text: "Enter Your Bug Detail")
        
        // set final log file name which is going to be emailed
        SLog.shared.setLogFileName(text: "finalLog")
        
        
        //set nobe and line color
        SLog.shared.setKnobColor(color: .red)
        SLog.shared.setLineColor(color: .green)
                
        // set text view text, font name, font size, and text color
        SLog.shared.setTextViewBackgroundColor(backgroundColor: .brown)
        SLog.shared.setTextViewTextColor(color: .green)
        SLog.shared.setTextViewFont(fontName: "Marker Felt Thin")
        SLog.shared.setTextViewFontSize(fontSize: 17)
        
        // set title text, font name, font size and text color
        SLog.shared.setTitle(title: "Title Here")
        SLog.shared.setTitleFont(fontName: "Marker Felt Thin")
        SLog.shared.setTitleFontSize(fontSize: 22)
        SLog.shared.setTitleColor(color: .purple)

        // set send button view text, icon, font name, font size, and text color
        SLog.shared.setSendButtonText(text: "Send Button Text")
        SLog.shared.setSendBtnFont(fontName: "Marker Felt Thin")
        SLog.shared.setSendBtnFontSize(fontSize: 30)
        SLog.shared.setSendBtnTextColor(color: .green)
        SLog.shared.setSendButtonBackgroundColor(backgroundColor: .black)
        SLog.shared.setSendBtnImage(img: UIImage(named: "testImg")!)
        SLog.shared.hideSendBtnIcon(bool: true)


## Hide Show Report View

        // report alert view is true by default make the bool true 
        // if you want to hide the report view and open the mail directly 
        SLog.shared.hideReportDialogue(bool: false)
        
        
## Send Report

        // Send Report
        SLog.shared.sendReport(controller: self)
        
        
## Objective C Usage

        // import the pod file in .m file
        @import SmartLogs;
        
        // initilization sdk
        [[SLog shared] initilization ];

        // use the function of the pods
        [[SLog shared] summaryLogWithText:@"summary log"];
        [[SLog shared] detailLogWithText:@"detail log" writeIntoFile:false];

        // call the alert view Controller
        [[SLog shared] sendReportWithController: self];
        

## Log Levels

The following log levels are supported:

 - `Debug`
 - `Info`
 - `Warning`
 - `Error`
 - `Message`


## Author

Whizpool, zzeeshan@gmail.com


## License

SmartLogs is available under the MIT license. See the LICENSE file for more info.


## Pod release and update new release



 ****************************************  Steps SDK / POD creation and publishing to Cocoapod.Org ****************************************


- Create the git hub repository with the official name for the SDK / POD 

- repository should be public with the MIT License

- now open the terminal go to the desktop and create the SDK support project by following command
    - “ pod lib create POD_NAME ”

- terminal will ask 5 question :- 
    - 
    - What platform do you want to use?? [ iOS / macOS ] -> iOS
        - choose you plateform you are woking.

    - What language do you want to use?? [ Swift / ObjC ] -> swift
        - choose you language you are woking.

    - Would you like to include a demo application with your library? [ Yes / No ] -> Yes
        - choose respectively if you want the demo app inside the pod project.

     - Which testing frameworks will you use? [ Quick / None ] -> None
     - Would you like to do view based testing? [ Yes / No ] -> No


- now your project is created and will be open automatically

- do some code here in your SDK files and run it using example project inside the pod project to see the results

- if you want to use any third party pod in the side the SDK library you need to mention the pod name in example Project and 
POD_NAME.podspec file as well (eg) “ s.dependency ‘SSZipArchive’ ”


    - for pod file pod ‘SSZipArchive’

- now install the pod in the parent folder where the pod file exist 

- review the pod spec file for example check the GitHub url, emails you want to register and pod name etc

- in the end when the you SDK is ready push the initial commit to git hub using Github desktop

- make the release with the same version mentioned in the pod spec file 

- open the terminal at the main folder for the SDK and run the command

    - pod lib lint 

    - this will verify your pod and return success if none error found on the other hand it will return the errors and you have to
    solve those error, without them pod will not be uploaded to the cocoapod.org

    - once you get the success from pod lib lint after resolving the error push the latest code and make a new release 
    on git hub (don’t forgot to increase / change the version number manually in pod spec file )

    - now your version is 0.4.0

// **********************************************
    this email registration is done. only for the first time. 

- go back to the terminal and run command to register your email shared in the pod spec file with this command
    “ pod register ‘YOUR_EMAIL’ ‘OWNER NAME ’ ”

- once your email / account is register run the command for the publishing / uploading the pod to the Cocoapod.org
// **********************************************

- run command “ pod trunk push “ 

- CONGRATS YOU POD IS UPLOADED / PUBLISHED AND WILL BE AVAILABLE FOR OPERATIONAL PURPOSES 

Note :- you must need to be opened terminal at the main folder of you SKD


