//
//  DatumView.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/17/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bezier.h"

@interface DatumView : UIView
{
    UIImageView* sunsetImage;
    UILabel* label;
}

-(id)initSunsetWithAFrame:(CGRect)frameInit;
-(id)initSunriseWithAFrame:(CGRect)frameInit;

-(id)initHighTideWithAFrame:(CGRect)frameInit;
-(id)initLowTideWithAFrame:(CGRect)frameInit;

-(id)initMainSwellWithAFrame:(CGRect)frameInit;
-(id)initSecondSwellWithAFrame:(CGRect)frameInit;

-(void)updateLabelStr:(NSString*)strInit;

@end