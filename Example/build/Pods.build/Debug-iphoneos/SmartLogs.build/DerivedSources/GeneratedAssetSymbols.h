#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"org.cocoapods.SmartLogs";

/// The "alertView" asset catalog color resource.
static NSString * const ACColorNameAlertView AC_SWIFT_PRIVATE = @"alertView";

/// The "color" asset catalog color resource.
static NSString * const ACColorNameColor AC_SWIFT_PRIVATE = @"color";

/// The "sendBtnColor" asset catalog color resource.
static NSString * const ACColorNameSendBtnColor AC_SWIFT_PRIVATE = @"sendBtnColor";

/// The "textViewColor" asset catalog color resource.
static NSString * const ACColorNameTextViewColor AC_SWIFT_PRIVATE = @"textViewColor";

/// The "sendIcon" asset catalog image resource.
static NSString * const ACImageNameSendIcon AC_SWIFT_PRIVATE = @"sendIcon";

#undef AC_SWIFT_PRIVATE
