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
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, frame.size.width/3 - 20, 25)];
    titleLabel.font = [UIFont boldSystemFontOfSize:23];
    [self addSubview:titleLabel];
    
    spitcastLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width - 155, 0, 175, 25)];
    spitcastLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:spitcastLabel];
    spitcastLabel.text = @"(Powered by Spitcast.com)";
    
    return self;
}

-(void)updateFrame:(CGRect)newFrame forCurrentView:(int)currentViewTag
{
    self.frame = newFrame;
    _theChartView.frame = CGRectMake(0, 30, newFrame.size.width, newFrame.size.height - 30);
    spitcastLabel.frame = CGRectMake(self.frame.size.width - 155, 0, 175, 25);
    if (currentViewTag == 1)
    {
        titleLabel.text = @"SURF";
    }
    else if(currentViewTag == 2)
    {
        titleLabel.text = @"WIND";
    }
    else
    {
        titleLabel.text = @"TIDE";
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
        //these don't work anymore?
//        _theChartView.infoTextColor = [UIColor blackColor];
//        _theChartView.infoFont = [UIFont boldSystemFontOfSize:15];
    }
}

-(void)plotData
{
    
    //INITIALIZE X AXIS VALUES ARRAY
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    
    int hour = 0;
    //ADD THE DISTANCE TRAVELED VALUE TO X AXIS DATA
    for (int i = 0; i < [yData count]; i++)
    {
        hour = hour + 1;
        //ADDS AS A STRING FOR PLOTTING PURPOSES
        NSString* aValString = [NSString stringWithFormat:@"%@",[xDataNameTags objectAtIndex:i]];
        [xVals addObject:aValString];
    }
    
    //INITIALIZE THE DATA SETS ARRAYS
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    NSMutableArray* yVals = [[NSMutableArray alloc] init];
    
//    ////////////////
//    NSMutableArray* y = [[NSMutableArray alloc] init];
//    [y addObject:[yData objectAtIndex:0]];
//    
//    double beta = 0.1;
//    
//    for (int i = 1; i < [yData count]; i++)
//    {
//        double nextNum = beta*[[yData objectAtIndex:i] doubleValue] + (1-beta)*[[y objectAtIndex:(i-1)] doubleValue];
//        
//        [y insertObject:[NSNumber numberWithDouble:nextNum] atIndex:i];
//    }
//    ////////////////

//    double max = 0;
    
    //ADD GROUND POINTS TO THE CHARTING DATA SETS
    for (int i = 0; i < [yData count]; i++)
    {
        double val = [[yData objectAtIndex:i] doubleValue];
//        if (val > max)
//        {
//            max = val;
//        }
        [yVals addObject:[[ChartDataEntry alloc] initWithX:i y:val]];
//        [yVals addObject:[[ChartDataEntry alloc] initWithValue:val xIndex:i]];
    }
    
    //GROUND DATA AND ASTHETICS
//    LineChartDataSet* dYData = [[LineChartDataSet alloc] initWithYVals:yVals label:plotLabel];
    LineChartDataSet* dYData = [[LineChartDataSet alloc] initWithValues:yVals label:plotLabel];
    dYData.lineWidth = 4;
    dYData.circleRadius = 4.0;
    dYData.drawCubicEnabled = YES;
    [dYData setColor:[UIColor blueColor]];
    [dYData setCircleColor:[UIColor clearColor]];

    //get colors from the preference factory soon
    //GROUND GRADIENT
    NSArray *gradientColors = @[(id)[ChartColorTemplates colorFromString:@"#3871cb"].CGColor,
                                (id)[ChartColorTemplates colorFromString:@"#3894cb"].CGColor];
    CGGradientRef gradient = CGGradientCreateWithColors(nil, (CFArrayRef)gradientColors, nil);
    dYData.fillAlpha = 0.5f;
    dYData.fill = [ChartFill fillWithLinearGradient:gradient angle:90.f];
    dYData.drawFilledEnabled = YES;
    CGGradientRelease(gradient);
    
    
    
    //ADDING THE CURRENT TIME BAR
    int currentTimeCount = [DateHandler getIndexFromCurrentTime];
    
    NSMutableArray* currentBarVals = [[NSMutableArray alloc] init];
    for (int i = 0; i < [yData count]; i++)
    {
        if ( i == currentTimeCount)
        {
//            [currentBarVals addObject:[[ChartDataEntry alloc] initWithValue:[[yData objectAtIndex:i] doubleValue] xIndex:currentTimeCount]];
            [currentBarVals addObject:[[ChartDataEntry alloc] initWithX:currentTimeCount y:[[yData objectAtIndex:i] doubleValue]]];
        }
        else
        {
//            [currentBarVals addObject:[[ChartDataEntry alloc] initWithValue:0 xIndex:currentTimeCount]];
                        [currentBarVals addObject:[[ChartDataEntry alloc] initWithX:currentTimeCount y:0]];
        }
    }
    
//    LineChartDataSet* dCurrentBar = [[LineChartDataSet alloc] initWithYVals:currentBarVals label:@"current time"];
    
    LineChartDataSet* dCurrentBar = [[LineChartDataSet alloc] initWithValues:currentBarVals label:@"current time"];
    
    dCurrentBar.lineWidth = 5;
    [dCurrentBar setCircleColor:[UIColor clearColor]];
    [dCurrentBar setColor:[UIColor blackColor]];
    dCurrentBar.circleRadius = 0;
    

    
    //ADD THE DATA SETS
        [dataSets addObject:dCurrentBar];
    [dataSets addObject:dYData];

    //INITALIZE & ADD THE DATA FOR PLOTTING
//    LineChartData *data = [[LineChartData alloc] initWithXVals:xVals dataSets:dataSets];
// //   [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:0]];
    
    LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
    
    //FORMAT X-AXIS
    ChartXAxis* xAxis = _theChartView.xAxis;
    xAxis.drawGridLinesEnabled = YES;
    xAxis.labelPosition = XAxisLabelPositionBottom;

    //different labeling when hours or days are shown.
    if ([xVals count] > 25)
    {
//        [xAxis setLabelsToSkip:24];
    }
    else
    {
//        [xAxis resetLabelsToSkip];
    }
//    [xAxis setLabelsToSkip:24];
    xAxis.labelFont =[UIFont fontWithName:@"HelveticaNeue-Light" size:20.f];
    
    //FORMAT Y-AXIS
    ChartYAxis* Yaxis = _theChartView.leftAxis;
    //Yaxis.valueFormatter = [[NSNumberFormatter alloc] init]; //this used to work
    
//    Yaxis.axisRange = 5;
//    Yaxis.axisMaxValue = 4;
    Yaxis.axisMinValue = 0;
    Yaxis.labelCount = 2; //2 is the min
    Yaxis.granularityEnabled = YES;
//    Yaxis.valueFormatter.minimumFractionDigits = 0;
//    Yaxis.valueFormatter.positiveSuffix = indicatorVal;
    Yaxis.labelFont =[UIFont fontWithName:@"HelveticaNeue-Light" size:20.f];

    ChartYAxis* rightAxis = _theChartView.rightAxis;
   // rightAxis.valueFormatter =[[NSNumberFormatter alloc] init];
    rightAxis.enabled = NO;
//    rightAxis.axisMinValue = 0;
//    rightAxis.labelCount = 2;
//    rightAxis.granularityEnabled = YES;
//    rightAxis.valueFormatter.minimumFractionDigits = 0;
//    rightAxis.valueFormatter.positiveSuffix = indicatorVal;
//    rightAxis.labelFont =[UIFont fontWithName:@"HelveticaNeue-Light" size:20.f];

    //SET THE DATA PROPERTY
    [_theChartView setData:data];
    
    [_theChartView setDescriptionText:@""];
    
    
    //ANIMATION
    //    [chartView animateWithYAxisDuration:1.5];
//    [chartView animateWithXAxisDuration:1.5];
    //    chartView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    
    //CHART LEGEND
    ChartLegend *legend = _theChartView.legend;
    legend.position = ChartLegendPositionAboveChartLeft;
    legend.position = ChartLegendPositionBelowChartLeft;
    [legend setEnabled:NO];
    legend.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.f];
    _theChartView.userInteractionEnabled = NO;
    
}

////CHART DELEGATE METHODS
//- (void)chartValueSelected:(ChartViewBase* __nonnull)chartView entry:(ChartDataEntry*__nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight*__nonnull)highlight
//{
////    CLLocationCoordinate2D aCoord = [[[theElevHandler getAllCoordArray] objectAtIndex:entry.xIndex] coordinate];
//    
//    NSLog(@"chartValueSelected %@",entry);
//    //    infoLabel.text = [NSString stringWithFormat:@"Lat:%3.3f Long:%3.3f Elev:%3.0f",aCoord.latitude,aCoord.longitude,entry.value];
//}
//- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
//{
//    NSLog(@"chartValueNothingSelected");
//    //    infoLabel.text = @"";
//}
//

@end
