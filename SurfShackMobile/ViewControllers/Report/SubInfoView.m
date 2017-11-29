//
//  SubInfoView.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 9/3/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubInfoView.h"

@implementation SubInfoView

-(id)initWithFrame:(CGRect)frameInit
{
    self = [super initWithFrame:frameInit];
    
    self.frame = frameInit;
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, frameInit.size.width/3 - 20, frameInit.size.height/4)];
    titleLabel.text = @"SURF";
    titleLabel.font = [UIFont boldSystemFontOfSize:23];
    
    
    infoTextView = [[UITextView alloc] initWithFrame:CGRectMake(10,frameInit.size.height/4, frameInit.size.width - 20, 3*frameInit.size.height/4)];
    
    infoTextView.scrollEnabled = NO;
    [infoTextView setEditable:NO];
    infoTextView.font = [UIFont systemFontOfSize:17];
    
    [self addSubview:titleLabel];
    
    return self;
}

-(void)updateInfoFromDict:(NSMutableDictionary*)spotDictInit forView:(int)viewTag
{
    int currentTimeIndex = [DateHandler getIndexFromCurrentTime];
    

    if (viewTag == 1) //surf
    {
        titleLabel.text = @"SURF";
        
        NSString* swellStr = [[NSString alloc] init];
        swellStr = @"";
        NSMutableArray* weekSwellArray = [spotDictInit objectForKey:@"swellDict"];
        NSMutableArray* todaySwellArray = [weekSwellArray objectAtIndex:0];
        NSMutableArray* currentSwellDataArray = [[todaySwellArray objectAtIndex:currentTimeIndex] getSwellDataArray];
        
        if (currentSwellDataArray != nil)
        {
            
            for (int i = 0 ; i < [currentSwellDataArray count]; i++)
            {
                double tp = [[[currentSwellDataArray objectAtIndex:i] objectForKey:@"tp"] doubleValue];
                double hs = [[[currentSwellDataArray objectAtIndex:i] objectForKey:@"hs"] doubleValue];
                double hst = [[todaySwellArray objectAtIndex:currentTimeIndex] getHST];
                double height = hs*hst;
                int direction = [[[currentSwellDataArray objectAtIndex:i] objectForKey:@"dir"] intValue] + 180;
                
                NSString* directionStr = [self getStringFromHeading:direction];
                NSString* str = [NSString stringWithFormat:@"Height: %.fft @ Period: %.fs From %@\n",height,tp,directionStr];
               swellStr = [swellStr stringByAppendingString:str];
                NSLog(@"%@",swellStr);
            }
            
        }
        
        infoTextView.text = swellStr;
    }
    else if(viewTag == 2) //wind
    {
        titleLabel.text = @"WIND";
        
        NSMutableArray* windDirectionArr = [[spotDictInit objectForKey:@"wind"] objectForKey:@"windDirectionArray"];
        
        double currentDir = [[windDirectionArr objectAtIndex:currentTimeIndex] doubleValue];
        double currentVal = [[[[spotDictInit objectForKey:@"wind"] objectForKey:@"mags"] objectAtIndex:currentTimeIndex] doubleValue];
        NSString* indicatorStr = [[spotDictInit objectForKey:@"wind"] objectForKey:@"inidicatorStr"];
        
        NSString* dirStr = [self getStringFromHeading:currentDir];
        
        infoTextView.text = [NSString stringWithFormat:@"%@, at %.f%@",dirStr,currentVal,indicatorStr];
    }
    else if (viewTag == 3)//tide
    {
        titleLabel.text = @"TIDE";
    }

}


-(NSString*)getStringFromHeading:(double)heading
{
    NSString* headingStr;
    
    if (heading > 337.5 || heading < 22.5)
    {
        headingStr = @"N";
    }
    else if (heading >= 22.5 && heading <= 67.5)
    {
        headingStr = @"NE";
    }
    else if (heading > 67.5 && heading <= 112.5)
    {
        headingStr = @"E";
    }
    else if (heading > 112.5 && heading <= 157.5)
    {
        headingStr = @"SE";
    }
    else if (heading > 157.5 && heading <= 202.5)
    {
        headingStr = @"S";
    }
    else if (heading > 202.5 && heading <= 247.5)
    {
        headingStr = @"SW";
    }
    else if (heading > 247.5 && heading <= 292.5)
    {
        headingStr = @"W";
    }
    else if (heading > 292.5 && heading <= 337.5)
    {
        headingStr = @"NW";
    }
    
    return headingStr;
}



@end
