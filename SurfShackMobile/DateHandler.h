//
//  DateHandler.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/18/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppUtilities.h"

@interface DateHandler : NSObject
{
    
}

+(NSString*)getCurrentDateString;

+(NSString*)getDateString:(NSDate*)dateInit;

+(NSMutableArray*)getArrayOfDayStrings:(int)numberOfDays;

+(NSString*)getDateNumberFromDateStr:(NSString*)dayInit;

//+(NSString*)change24HourTo12:(int)timeInit;

+(NSString*)getCurrentDay;
+(NSString*)getDayStringFromSpitDate:(NSString*)spitDateInit;


+(NSDictionary*)getMonthDictFromFile;
+(void)writeMonthDictionaryToFile;

+(NSString*)getTimeFromPST:(NSString*)pstInit;

+(NSString*)getTimeFromIndex:(int)index;

+(int)getIndexFromCurrentTime;
@end