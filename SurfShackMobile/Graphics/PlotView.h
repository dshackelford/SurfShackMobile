//
//  PlotView.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/13/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateHandler.h"
#import "PreferenceFactory.h"

@import Charts;

@interface PlotView : UIView <ChartViewDelegate, IChartAxisValueFormatter>
{
    NSMutableArray* yData;
    NSMutableArray* xDataNameTags;
    NSString* indicatorVal;
    NSString* plotLabel;
    
    UILabel* titleLabel;
    UILabel* spitcastLabel;
    
    NSMutableArray* xVals;
}

@property BOOL isOfflineData;
@property (nonatomic, strong) IBOutlet LineChartView* chartView;
@property (nonatomic,strong) IBOutlet LineChartView* theChartView;

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NSMutableArray *customConstraints;

-(void)updateFrame:(CGRect)newFrame forCurrentView:(int)currentViewTag;

-(void)establishViewWithData:(NSMutableArray*)yDataArr withXVals:(NSMutableArray*)xValInit withIndicatorVal:(NSString*)indicatorValStr andPlotLabel:(NSString*)plotLabelInit;
-(NSMutableArray*)getYData;
@end
