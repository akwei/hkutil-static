//
//  CfgHeader.h
//  hkutil-static
//
//  Created by akwei on 13-9-27.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

// Compiling for iOS

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000 // iOS 6.0 or later
#define NEEDS_DISPATCH_RETAIN_RELEASE 0
#else                                         // iOS 5.X or earlier
#define NEEDS_DISPATCH_RETAIN_RELEASE 1
#endif
