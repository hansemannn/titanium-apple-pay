/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2015 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import <Foundation/Foundation.h>
#import "TiApplepayConstants.h"

@interface TiApplepayPaymentGatewayConfiguration : NSObject

@property(nonatomic,retain) NSString *apiKey;
@property(nonatomic,assign) TiApplepayPaymentGateway paymentProvider;

+(id)sharedConfig;

@end
