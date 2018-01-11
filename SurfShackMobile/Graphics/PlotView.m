//
//  PlotView.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/13/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlotView.h"

@implementation PlotView

@synthesize chartView;

#pragma mark - Set Up
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.frame = frame;
    
    _theChartView = [[LineChartView alloc] initWithFrame:CGRectMake(0, 30, frame.size.width, frame.size.height -30)];
    _theChartView.delegate = self;
    [self addSubview:_theChartView];
    _theChartView.noDataText = @"";
    _theChartView.backgroundColor = [UIColor clearColor];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, frame.size.width/2 - 20, 25)];
    titleLabel.font = [UIFont boldSystemFontOfSize:23];
    [self addSubview:titleLabel];
    
    spitcastLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 155, 0, 175, 25)];
    spitcastLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:spitcastLabel];
    spitcastLabel.text = @"(Powered by Spitcast.com)";
    
    self.isOfflineData = true; //default to offline color sceme
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(futureIndexSet:) name:@"futureIndexRatio" object:nil];
    
    [self setUserInteractionEnabled:NO];
    
    return self;
}

-(void)futureIndexSet:(NSNotification*)notification
{
    NSNumber* indexRatio = notification.object;
    int index = [indexRatio doubleValue]*[yData count];
    
    if([indexRatio doubleValue] == -1)
    {
        //go to current time
        index = [DateHandler getIndexFromCurrentTime];
    }
    
    NSLog(@"plot changing index line to %i",index);
    NSMutableArray* currentBarVals = [[NSMutableArray alloc] init];
    [currentBarVals addObject:[[ChartDataEntry alloc] initWithX:index y:0]];
    [currentBarVals addObject:[[ChartDataEntry alloc] initWithX:index y:[[yData objectAtIndex:index] doubleValue]]];
    
    LineChartDataSet* dCurrentBar = [[LineChartDataSet alloc] initWithValues:currentBarVals label:@"Current Time"];
    dCurrentBar.lineWidth = 5;
    [dCurrentBar setCircleColor:[UIColor clearColor]];
    [dCurrentBar setColor:[UIColor blackColor]];
    dCurrentBar.circleRadius = 0;
    
    [_theChartView.data removeDataSetByIndex:1];
    
    [dCurrentBar setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:0]];
    [_theChartView.data addDataSet:dCurrentBar];
    
    [_theChartView setData:_theChartView.data];
}

-(void)updateFrame:(CGRect)newFrame forCurrentView:(int)currentViewTag
{
    _theChartView.pinchZoomEnabled = NO;
    _theChartView.doubleTapToZoomEnabled = NO;
    _theChartView.highlightPerTapEnabled = NO;
    _theChartView.highlightPerDragEnabled = NO;
    
    self.frame = newFrame;
    _theChartView.frame = CGRectMake(0, 30, newFrame.size.width, newFrame.size.height - 30);
    spitcastLabel.frame = CGRectMake(self.frame.size.width - 155, 0, 175, 25);
    if (currentViewTag == 1)
    {
        NSString* str = @"SURF (";
        str = [str stringByAppendingString:[PreferenceFactory getIndicatorStrForHeight]];
        str = [str stringByAppendingString:@")"];
        titleLabel.text = str;
    }
    else if(currentViewTag == 2)
    {
        NSString* str = @"WIND (";
        str = [str stringByAppendingString:[PreferenceFactory getIndicatorStrForSpeed]];
        str = [str stringByAppendingString:@")"];
        titleLabel.text = str;

    }
    else
    {
        NSString* str = @"TIDE (";
        str = [str stringByAppendingString:[PreferenceFactory getIndicatorStrForHeight]];
        str = [str stringByAppendingString:@")"];
        titleLabel.text = str;
    }
    
    
}

#pragma mark - Plotting
-(void)establishViewWithData:(NSMutableArray*)yDataArr withXVals:(NSMutableArray*)xValInit withIndicatorVal:(NSString*)indicatorValStr andPlotLabel:(NSString*)plotLabelInit
{
    yData = yDataArr;
    xDataNameTags = xValInit;
    indicatorVal = indicatorValStr;
    plotLabel = plotLabelInit;

    if ([yData count] > 0 && [xDataNameTags count] > 0)
    {
        [self plotData];
    }
    else //there is no data!!
    {
        _theChartView.noDataText = @" Sorry, there seems to be no surf data \n for this spot, try another spot close to this one.";
        [_theChartView setData:nil];
        //these don't work anymore?
//        _theChartView.infoTextColor = [UIColor blackColor];
//        _theChartView.infoFont = [UIFont boldSystemFontOfSize:15];
    }
}

-(void)plotData
{
    //INITIALIZE X AXIS VALUES ARRAY
    xVals = [[NSMutableArray alloc] init];

    if ([yData count] == 24) //one day showing (with hours on x-axis)
    {
        for (int i = 0; i < [yData count]; i++)
        {
            //ADDS AS A STRING FOR PLOTTING PURPOSES
            NSString* aValString; //hide the 0th hours(technically the
            if (i == 0 || i == 23) //don't want to show 0AM and 11PM
            {
                aValString = [NSString stringWithFormat:@""];
            }
            else
            {
                if (i < 12) //morning hours
                {
                    aValString = [NSString stringWithFormat:@"%@AM",[xDataNameTags objectAtIndex:i]];
                }
                else //afternoon hours
                {
                    aValString = [NSString stringWithFormat:@"%@PM",[xDataNameTags objectAtIndex:i]];
                }
            }
            
            [xVals addObject:aValString];
        }
    }
    else //show days
    {
        for (int i = 0; i < [yData count]; i++)
        {
//            NSLog(@"%i, %@",i,[xDataNameTags objectAtIndex:i]);
            NSString* aValString = [xDataNameTags objectAtIndex:i];
            
            [xVals addObject:aValString];
        }
    }
    
    //INITIALIZE THE DATA SETS ARRAYS
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    NSMutableArray* yVals = [[NSMutableArray alloc] init];
    
    //    //SMOOTHING DATA
//        NSMutableArray* y = [[NSMutableArray alloc] init];
//        [y addObject:[yData objectAtIndex:0]];
//    
//        double beta = 0.1;
//    
//        for (int i = 1; i < [yData count]; i++)
//        {
//            double nextNum = beta*[[yData objectAtIndex:i] doubleValue] + (1-beta)*[[y objectAtIndex:(i-1)] doubleValue];
//    
//            [y insertObject:[NSNumber numberWithDouble:nextNum] atIndex:i];
//        }
//    yData = y;
    
    //    ////////////////
    
    //SPITCAST DATA
    double max = -1000;
    double min = 1000;
    for (int i = 0; i < [yData count]; i++)
    {
        double val = [[yData objectAtIndex:i] doubleValue];
        
        //change the units to meter if necessary
        if([indicatorVal isEqualToString:@"m"])
        {
            val = val*0.3048; //change ft to m
        }
        else if([indicatorVal isEqualToString:@"kts"])
        {
            val = val*0.868976; //
        }
        
        [yVals addObject:[[ChartDataEntry alloc] initWithX:i y:val]];
        
        if (val > max)
        {
            max = val;
        }
        
        if(val < min)
        {
            min = val; //determine the minimum value so that the graph does not "bottom out"
        }
    }
    
    //COLOR PREFERENCE
    NSDictionary* prefs = [PreferenceFactory getPreferences];
    
    UIColor* color = [prefs objectForKey:kColorScheme];
    
    if(self.isOfflineData)
    {
        color = [UIColor grayColor];
    }
    
    //MAIN DATA
    LineChartDataSet* dYData = [[LineChartDataSet alloc] initWithValues:yVals label:plotLabel];
    dYData.lineWidth = 4;
    dYData.circleRadius = 4.0;
    dYData.drawCubicEnabled = YES;
    
    [dYData setColor:color];
    [dYData setCircleColor:[UIColor clearColor]]; //don't want individual data points showing
    dYData.axisDependency = AxisDependencyLeft;

    
    //GRADIENT COLORS
    NSArray* gradientColors = @[(id)color.CGColor,(id)[UIColor clearColor].CGColor];
    CGGradientRef gradient = CGGradientCreateWithColors(nil, (CFArrayRef)gradientColors, nil);
    dYData.fillAlpha = 0.5f;
    dYData.fill = [ChartFill fillWithLinearGradient:gradient angle:90.f];
    dYData.drawFilledEnabled = YES;
    CGGradientRelease(gradient);
    
    //CURRENT TIME BAR
    int currentTimeCount = [DateHandler getIndexFromCurrentTime];
    NSLog(@"current time count: %i",currentTimeCount);
    NSMutableArray* currentBarVals = [[NSMutableArray alloc] init];
    [currentBarVals addObject:[[ChartDataEntry alloc] initWithX:currentTimeCount y:0]];
    [currentBarVals addObject:[[ChartDataEntry alloc] initWithX:currentTimeCount y:[[yData objectAtIndex:currentTimeCount] doubleValue]]];
    
    LineChartDataSet* dCurrentBar = [[LineChartDataSet alloc] initWithValues:currentBarVals label:@"Current Time"];
    dCurrentBar.lineWidth = 5;
    [dCurrentBar setCircleColor:[UIColor clearColor]];
    [dCurrentBar setColor:[UIColor blackColor]];
    dCurrentBar.circleRadius = 0;
    
    //ADD THE DATA SETS
    [dataSets addObject:dYData];
    [dataSets addObject:dCurrentBar];
    LineChartData* data = [[LineChartData alloc] initWithDataSets:dataSets];
    [_theChartView setData:data];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:0]];     //removes the number values of each point
    
    //FORMAT X-AXIS
    ChartXAxis *xAxis = _theChartView.xAxis;
    xAxis.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.f];
    xAxis.granularity = 1.f;
    xAxis.centerAxisLabelsEnabled = YES; //makes the numbers under the actual grid lines
    xAxis.labelPosition = XAxisLabelPositionBottom; //puts the labels on the bottom line
    xAxis.valueFormatter = self; //tells the protocol to adopt the value to string conversion!
    xAxis.axisMinimum = 0;
    
    //different labeling when hours or days are shown.
    if ([xVals count] == 24) //showing hours of the day
    {
        [xAxis setLabelCount:5 force:YES];
        xAxis.centerAxisLabelsEnabled = NO;
    }
    else if([xVals count] == 48)
    {
        [xAxis setLabelCount:3 force:YES];
        xAxis.centerAxisLabelsEnabled = YES;
    }
    else if([xVals count] == 72)
    {
        [xAxis setLabelCount:4 force:YES];
        xAxis.centerAxisLabelsEnabled = YES;
    }
    else if([xVals count] == 96)
    {
        [xAxis setLabelCount:5 force:YES];
        xAxis.centerAxisLabelsEnabled = YES;
    }
    else if([xVals count] == 120)
    {
        [xAxis setLabelCount:6 force:YES];
        xAxis.centerAxisLabelsEnabled = YES;
    }
    else if([xVals count] == 144)
    {
        [xAxis setLabelCount:7 force:YES];
        xAxis.centerAxisLabelsEnabled = YES;
    }
    else if([xVals count] == 168)
    {
        [xAxis setLabelCount:8 force:YES];
        xAxis.centerAxisLabelsEnabled = YES;
    }
    
    //FORMAT Y-AXIS
    ChartYAxis* Yaxis = _theChartView.leftAxis;
    Yaxis.labelCount = 3; //2 is the min
    Yaxis.granularityEnabled = YES; //no decimal points
    Yaxis.labelFont =[UIFont fontWithName:@"HelveticaNeue-Light" size:20.f];
    Yaxis.valueFormatter = self; //tells the protocol to adopt the value to string conversion!
    Yaxis.axisMaximum = max + 1;

//    if(min >= 0)
//    {
        Yaxis.axisMinimum = 0;
        Yaxis.axisRange = max + 1;
//    }
//    else
//    {
////        Yaxis.axisMinimum = min - 1;
//    }
    
    ChartYAxis* rightAxis = _theChartView.rightAxis;
    rightAxis.enabled = NO;
    
    //CHART LEGEND
    ChartLegend *legend = _theChartView.legend;
    legend.position = ChartLegendPositionAboveChartLeft;
    legend.position = ChartLegendPositionBelowChartLeft;
    legend.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.f];
    [legend setEnabled:NO]; //don't add the legend in the ui view
    
    //UIVIEW HANDLING
    //_theChartView.userInteractionEnabled = NO; //cannot click and drag the on the plot
    
    [_theChartView sizeToFit];
    [_theChartView setDescriptionText:@""];
}

//PROTOCOL IMPLEMENTATION FOR ICHARTAXISVALUEFORMATTER (WRITES THE LABLES ON AXIS VALUES
-(NSString*)stringForValue:(double)value axis:(ChartAxisBase *)axis
{
    value = ceil(value);
    
    if (value < 0)
    {
        return [NSString stringWithFormat:@"w"];
    }
    if ([axis isKindOfClass:[ChartXAxis class]])
    {
//        NSLog(@"X: %f",value);
        if (value < [xVals count])
        {
            return [xVals objectAtIndex:value];
        }
        else
        {
            return [NSString stringWithFormat:@"x"];
        }
    }
    else
    {
//        NSString* str = [NSString stringWithFormat:@"%.f%@",value,indicatorVal]; //unit indicator here
        NSString* str = [NSString stringWithFormat:@"%.f",value]; //unit indicator here
        return str;
    }
}
//CHART DELEGATE METHODS

-(void)chartValueSelected:(ChartViewBase *)chartView entry:(ChartDataEntry *)entry highlight:(ChartHighlight *)highlight
{
    //CURRENT TIME BAR
    NSLog(@"current time count: %f",entry.x);
    NSMutableArray* currentBarVals = [[NSMutableArray alloc] init];
    [currentBarVals addObject:[[ChartDataEntry alloc] initWithX:entry.x y:0]];
    [currentBarVals addObject:[[ChartDataEntry alloc] initWithX:entry.x y:[[yData objectAtIndex:entry.x] doubleValue]]];
    
    LineChartDataSet* dCurrentBar = [[LineChartDataSet alloc] initWithValues:currentBarVals label:@"Current Time"];
    dCurrentBar.lineWidth = 5;
    [dCurrentBar setCircleColor:[UIColor clearColor]];
    [dCurrentBar setColor:[UIColor blackColor]];
    dCurrentBar.circleRadius = 0;
    
    [_theChartView.data removeDataSetByIndex:1];
    
    [dCurrentBar setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:0]];
    [_theChartView.data addDataSet:dCurrentBar];
    [chartView highlightValue:nil];
}

-(void)chartValueNothingSelected:(ChartViewBase *)chartView
{
    NSLog(@"nothing selected on chart view");
    
    int currentTimeCount = [DateHandler getIndexFromCurrentTime];
    NSLog(@"current time count: %i",currentTimeCount);
    NSMutableArray* currentBarVals = [[NSMutableArray alloc] init];
    [currentBarVals addObject:[[ChartDataEntry alloc] initWithX:currentTimeCount y:0]];
    [currentBarVals addObject:[[ChartDataEntry alloc] initWithX:currentTimeCount y:[[yData objectAtIndex:currentTimeCount] doubleValue]]];
    
    LineChartDataSet* dCurrentBar = [[LineChartDataSet alloc] initWithValues:currentBarVals label:@"Current Time"];
    dCurrentBar.lineWidth = 5;
    [dCurrentBar setCircleColor:[UIColor clearColor]];
    [dCurrentBar setColor:[UIColor blackColor]];
    dCurrentBar.circleRadius = 0;
    
    [_theChartView.data removeDataSetByIndex:1];
    
    [dCurrentBar setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:0]];
    [_theChartView.data addDataSet:dCurrentBar];
}

-(NSMutableArray*)getYData
{
    return yData;
}

@end
