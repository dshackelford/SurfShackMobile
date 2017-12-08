//
//  CompassView.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/17/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CompassView.h"

@implementation CompassView

-(id)initWithFrame:(CGRect)frameInit
{
    self = [super initWithFrame:frameInit];
    
    self.frame = frameInit;
    
    angle = 0;
    
//    [self addDirectionLabel];
    [self addCompass];
    [self establishTrianglePath];
    [self addDatums];
    
    NSDictionary* prefs = [PreferenceFactory getPreferences];
    UIColor* color = [prefs objectForKey:kColorScheme];

//    [self addMarkerToCompassOfColor:[UIColor colorWithRed:22/255.f green:119/255.f blue:205/255.f alpha:1]];
    [self addMarkerToCompassOfColor:color];
    
    marker1.hidden = YES;

    
    return self;
}


-(void)addCompass
{
    //create the marker view that will hold the markers
    markerView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - self.frame.size.height/2,0,self.frame.size.height, self.frame.size.height)];
    [self addSubview:markerView];
    
    //COMPASS RIM
    UIBezierPath* rimPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(5,5, self.frame.size.height/1.75, self.frame.size.height/1.75)];
    
    rim = [Bezier draw:rimPath inView:self atPoint:CGPointMake(self.frame.size.width/2,self.frame.size.height/2) ofSize:CGSizeMake(self.frame.size.height/1.75 + 10, self.frame.size.height/1.75 + 10)];
    
    //110, 120
    [self addSubview:rim];
    rim.hidden = YES;
    
    
    //COMPASS LABELS
    tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 50, self.frame.size.height/2 - 50, 100, 100)];
    [self addSubview:tempLabel];
    tempLabel.textAlignment  = NSTextAlignmentCenter;
    tempLabel.hidden = YES;
}

-(void)establishTrianglePath
{
    //5 pixel biffer on top of triangle
    trianglePath = [UIBezierPath bezierPath];
    [trianglePath moveToPoint:CGPointMake(15,15)];
    [trianglePath addLineToPoint:CGPointMake(45,25)];
    [trianglePath addLineToPoint:CGPointMake(40, 15)];
    [trianglePath addLineToPoint:CGPointMake(45,5)];
    [trianglePath addLineToPoint:CGPointMake(15,15)];
    [trianglePath closePath];
}

-(void)addMarkerToCompassOfColor:(UIColor*)colorInit
{
    [marker1 removeFromSuperview];
    
    //add marker to the right side of rim
    //the 7.5 is based of trial and error
    //the 7 is just give it a white gap between triangle and rim
    
    marker1 = [Bezier drawColored:trianglePath inView:self atPoint:CGPointMake(markerView.frame.size.width/2 + rim.frame.size.width/2 + 8,markerView.frame.size.height/2 + 7.5) withColor:[UIColor blackColor] ofSize:CGSizeMake(45, 45)];
//    [marker1 setFrame:CGRectMake(marker1.frame.origin.x, marker1.frame.origin.y, 25, 25)];
    
    [markerView addSubview:marker1];
}

-(void)addDatums
{
    //ADDING THE RIGHT AND LEFT DATUMS FOR WIND/SURF/TIDE
    sunsetDatum = [[DatumView alloc] initSunsetWithAFrame:CGRectMake(3*self.frame.size.width/4, 0 , self.frame.size.width/4, self.frame.size.height)];
    [self addSubview:sunsetDatum]; //rim.frame.origin.y + rim.frame.size.height + 60
    sunsetDatum.hidden = YES;
    
    sunriseDatum = [[DatumView alloc] initSunriseWithAFrame:CGRectMake(0,self.frame.size.height/5, self.frame.size.width/4, 3*self.frame.size.height/4)];
    [self addSubview:sunriseDatum];
    sunriseDatum.hidden = YES;
    
    highTideDatum = [[DatumView alloc] initHighTideWithAFrame:CGRectMake(3*self.frame.size.width/4,0 , self.frame.size.width/4, self.frame.size.height)];
    [self addSubview:highTideDatum];
    highTideDatum.hidden = YES;
    
    lowTideDatum = [[DatumView alloc] initLowTideWithAFrame:CGRectMake(0,self.frame.size.height/5, self.frame.size.width/4, 3*self.frame.size.height/4)];
    
    [self addSubview:lowTideDatum];
    lowTideDatum.hidden = YES;
    
    mainSwellDatum = [[DatumView alloc] initMainSwellWithAFrame:CGRectMake(3*self.frame.size.width/4,0 , self.frame.size.width/4, self.frame.size.height)];
    [self addSubview:mainSwellDatum];
    highTideDatum.hidden = YES;
    
    secondSwellDatum = [[DatumView alloc] initSecondSwellWithAFrame:CGRectMake(0,0, self.frame.size.width/4, 3*self.frame.size.height/4)];
    [self addSubview:secondSwellDatum];
    lowTideDatum.hidden = YES;
}

-(void)decideWhichDatumToShow:(int)currentTagInit withSpotDict:(NSDictionary*)dictInit andHeading:(float)headingInit
{

    tempLabel.hidden = NO;
    rim.hidden = NO;
    marker1.hidden = NO;
    currentTag = currentTagInit;
    
    [tideImage removeFromSuperview];
    
    if (currentTag == 1) //surf (show swell)
    {
//        titleLabel.text = @"SURF";
        sunsetDatum.hidden = YES;
        sunriseDatum.hidden = YES;
        highTideDatum.hidden = YES;
        lowTideDatum.hidden = YES;
        mainSwellDatum.hidden = NO;
        secondSwellDatum.hidden = NO;
        
        //show water temp
        NSLog(@"waterTemp: %@",[dictInit objectForKey:@"waterTemp"] );
        
        tempLabel.text = [NSString stringWithFormat:@"%@",[dictInit objectForKey:@"waterTemp"] ];
        tempLabel.font = [UIFont boldSystemFontOfSize:50];
        
        if([[dictInit objectForKey:@"waterTemp"] integerValue] == 0)
        {
            tempLabel.text = @"-"; //for asethetics purposes
        }
        
        [mainSwellDatum updateLabelStr:[dictInit objectForKey:@"mainSwellInfo"]];
        [secondSwellDatum updateLabelStr:[dictInit objectForKey:@"secondSwellInfo"]];
        
        markerInitialDegree = [[dictInit objectForKey:@"currentSwellDirection"] intValue];
        
        [self rotateMarkerView:headingInit];
    }
    else if(currentTag == 2) //wind (show sunset)
    {
//        titleLabel.text = @"WIND";
        sunsetDatum.hidden = NO;
        sunriseDatum.hidden = NO;
        highTideDatum.hidden = YES;
        lowTideDatum.hidden = YES;
        mainSwellDatum.hidden = YES;
        secondSwellDatum.hidden = YES;
        
        //show air temp
        NSDictionary* weatherDict = [dictInit objectForKey:@"weatherDict"];
        double temp = [[weatherDict valueForKey:@"temp"] doubleValue];
        tempLabel.text = [NSString stringWithFormat:@"%.f",temp];
        tempLabel.font = [UIFont boldSystemFontOfSize:50];
        //tempLabel.textAlignment = NSTextAlignmentCenter;
        //tempLabel.adjustsFontSizeToFitWidth = YES;
        [sunsetDatum updateLabelStr:[weatherDict objectForKey:@"sunset"]];
        [sunriseDatum updateLabelStr:[weatherDict objectForKey:@"sunrise"]];
        
        markerInitialDegree = [[dictInit objectForKey:@"windDirection"] intValue];
        
        [self rotateMarkerView:headingInit];
    }
    else //tide (show high and low
    {
//        titleLabel.text = @"TIDE";
        sunsetDatum.hidden = YES;
        sunriseDatum.hidden = YES;
        highTideDatum.hidden = NO;
        lowTideDatum.hidden = NO;
        mainSwellDatum.hidden = YES;
        secondSwellDatum.hidden = YES;
        
        tempLabel.text = @"";
        
        double percentageOfAngle = [[dictInit objectForKey:@"tideRatio"] doubleValue];
        
        double angleLeftTopOfBottom = M_PI/2 + percentageOfAngle*M_PI;
        double endAngleTopRight = 2*M_PI - (percentageOfAngle*M_PI - M_PI/2);
        
        UIBezierPath* partCirclePath = [UIBezierPath bezierPath];
        [partCirclePath addArcWithCenter:CGPointMake(rim.frame.size.width/2, rim.frame.size.width/2) radius:rim.frame.size.width/2 - 5 startAngle:angleLeftTopOfBottom endAngle:endAngleTopRight clockwise:NO];
        [partCirclePath closePath];
        
        
        tideImage = [Bezier drawColored:partCirclePath inView:self atPoint:CGPointMake(self.frame.size.width/2,self.frame.size.height/2) withColor:[UIColor colorWithRed:22/255.f green:119/255.f blue:205/255.f alpha:0.75] ofSize:CGSizeMake(rim.frame.size.width,rim.frame.size.height)];
        
        [self insertSubview:tideImage belowSubview:rim];
        
        [highTideDatum updateLabelStr:[dictInit objectForKey:@"nextHighTide"]];
        [lowTideDatum updateLabelStr:[dictInit objectForKey:@"nextLowTide"]];
        
        //ask if the tide is rising or not
        bool risingTide = [[dictInit objectForKey:@"risingTide"] boolValue];
        if(risingTide)
        {
            angle = -270; //angle is positive clockwise (degrees)
        }
        else
        {
            angle = -90;
        }
        markerView.transform = CGAffineTransformMakeRotation(angle * M_PI/180);
    }
    
}

//-(double)findRelativeTideHeight:(NSDictionary*)spotDictInit
//{
//    DataFactory* df = [[DataFactory alloc] init];
//    NSDictionary* tideDict = [spotDictInit objectForKey:@"tide"];
//    NSMutableArray* shortXVals = [df getShorternedVersionOfXValArray:[tideDict objectForKey:kDayArr] ofLength:[PreferenceFactory getShortRange]];
//    
//    double currentHeight = 0;
//    double max = 4;
//    
//    double percentageOfAngle = currentHeight/max;
//    
//    
//}
//moving the markers around the center point
-(void)rotateMarkerView:(double)degInit
{
    if (currentTag != 3)//don't rotate in tide View
    {
        //-90 to get marker to top of circle, then move to the where wind is blowing, the adjust it for how i rotate the device.
        angle = -90 + markerInitialDegree - degInit;
        markerView.transform = CGAffineTransformMakeRotation(angle * M_PI/180);
    }

}

-(void)updateColor
{
        NSDictionary* prefs = [PreferenceFactory getPreferences];
        UIColor* color = [prefs objectForKey:kColorScheme];
//    [self addMarkerToCompassOfColor:color];
}


@end
