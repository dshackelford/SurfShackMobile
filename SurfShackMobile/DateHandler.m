//
//  DateHandler.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/18/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DateHandler.h"


@implementation DateHandler

+(NSString*)getCurrentDateString
{
    NSDate* today = [NSDate dateWithTimeIntervalSinceNow:0];
    
    return [DateHandler getDateString:today];
}

//will return today as well
//what if numberOfDays is bigger then 7 and the spitcast returns that 505 error?
+(NSMutableArray*)getArrayOfDayStrings:(int)numberOfDays
{
    NSMutableArray* weekArray = [[NSMutableArray alloc] init];
    if (numberOfDays > 7)
    {
        numberOfDays = 7; //this is a cap on the data service
    }
    for (int i = 0; i < numberOfDays; i = i + 1)
    {
        NSDate* aDate = [DateHandler getDateOfFutureDay:i];
        NSString* aDayString = [DateHandler getDateString:aDate];
        [weekArray addObject:aDayString];
    }
    
    return weekArray;
}

+(NSDate*)getDateOfFutureDay:(int)daysInFuture
{
    NSDate* aDate = [NSDate dateWithTimeIntervalSinceNow:60*60*24*daysInFuture];
    return aDate;
}


//"Friday Jul 22, 2016" --> 20160722
+(NSString*)getDateString:(NSDate*)dateInit
{
    NSString* todayStr = [NSDateFormatter localizedStringFromDate:dateInit dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    
    NSString *stringWithoutcomma = [todayStr
                                     stringByReplacingOccurrencesOfString:@"," withString:@""];
    
    NSArray * arr = [stringWithoutcomma componentsSeparatedByString:@" "];
    
    NSString* month = [arr objectAtIndex:0];
    
    month = [[DateHandler getMonthDictFromFile] objectForKey:month];
    
    NSString* day = [arr objectAtIndex:1];
    
    if ([day length] < 2)
    {
        day = [NSString stringWithFormat:@"0%@",day];
    }
    
    NSString* year = [arr objectAtIndex:2];
    
    NSString* spitDate = [NSString stringWithFormat:@"%@%@%@",year,month,day];
    
    return spitDate;

}

//"Friday Jul 22 2016" --> 20160722
+(NSString*)getDateNumberFromDateStr:(NSString*)dayInit
{
    NSArray * arr = [dayInit componentsSeparatedByString:@" "];
    
    NSString* month = [arr objectAtIndex:1];
   
    month = [[DateHandler getMonthDictFromFile] objectForKey:month];
    
    NSString* day = [arr objectAtIndex:2];
    
    if ([day length] < 1)
    {
        day = [NSString stringWithFormat:@"0%@",day];
    }
    
    NSString* year = [arr objectAtIndex:3];
    
    NSString* spitDate = [NSString stringWithFormat:@"%@%@%@",year,month,day];
    
    return spitDate;
}


+(NSString*)getDayStringFromSpitDate:(NSString*)spitDateInit
{
    NSString* todaySpitDate = [DateHandler getCurrentDateString];
    
    return todaySpitDate;
}


+(NSString*)getCurrentDay
{
    NSDate* today = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString* todayStr = [NSDateFormatter localizedStringFromDate:today dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterLongStyle];
    
    [DateHandler getDayStringFromSpitDate:[DateHandler getDateString:today]];
    return todayStr;
    
}




+(NSDictionary*)getMonthDictFromFile
{
    if ([AppUtilities doesFileExistAtPath:[AppUtilities getPathToMonthFile]] == NO)
    {
        [DateHandler writeMonthDictionaryToFile];
    }
    
    return [NSDictionary dictionaryWithContentsOfFile:[AppUtilities getPathToMonthFile]];
}

+(void)writeMonthDictionaryToFile
{
    //ADDING TO THE DICTIONARY SHOULD HAPPEN IN THE SETTINGS
    NSArray* keys=@[@"Jan",@"Feb",@"Mar",@"Apr",@"May",@"Jun",@"Jul",@"Aug",@"Sep",@"Oct",@"Nov",@"Dec"];
    
    NSArray* objects=@[@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12"];
    
    NSMutableDictionary* myDictionary =[[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys];
    
    [myDictionary writeToFile:[AppUtilities getPathToMonthFile] atomically:YES ];
}


//this will get used with the time grabbed from OpenWeatherAPI
+(NSString*)getTimeFromPST:(NSString*)pstInit
{
    NSArray * arr = [pstInit componentsSeparatedByString:@":"];
    int hour = [[arr objectAtIndex:0] intValue];
    if (hour > 12)
    {
        hour = hour - 12;
    }
    NSString* hourStr = [NSString stringWithFormat:@"%d",hour];
    
    NSString* time;
    
    if ([[arr objectAtIndex:0] integerValue] > 12)
    {
        time = [NSString stringWithFormat:@"%@:%@PM",hourStr,[arr objectAtIndex:1]];
    }
    else
    {
        time = [NSString stringWithFormat:@"%@:%@AM",hourStr,[arr objectAtIndex:1]];
    }
    
    return time;
}

+(int)getIndexFromCurrentTime
{
    NSDate* ts_utc = [NSDate dateWithTimeIntervalSinceNow:0];
    
    NSDateFormatter* df_utc = [[NSDateFormatter alloc] init];
    [df_utc setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [df_utc setDateFormat:@"yyyy.MM.dd G 'at' HH:mm:ss zzz"];
    
    NSDateFormatter* df_local = [[NSDateFormatter alloc] init];
    [df_local setTimeZone:[NSTimeZone timeZoneWithName:@"PST"]];
    [df_local setDateFormat:@"HH:mm:ss"];
    
    NSString* ts_local_string = [df_local stringFromDate:ts_utc];
    
    NSArray * arr = [ts_local_string componentsSeparatedByString:@":"];
    int hour = [[arr objectAtIndex:0] intValue];
    
    return hour;
}


+(NSString*)getTimeFromIndex:(int)index
{
    if (index < 24) //within the current day
    {
        if (index < 11)
        {
            return [NSString stringWithFormat:@"%d AM",index + 1];
        }
        else
        {
            return [NSString stringWithFormat:@"%d PM",(index - 12)+ 1];
        }
        
    }
    else
    {
        int x = index/24;
        index = index - 24*x;
        
        if (index < 11)
        {
            return [NSString stringWithFormat:@"%d AM",index + 1];
        }
        else
        {
            return [NSString stringWithFormat:@"%d PM",(index - 12) + 1];
        }
    }
}



@end
