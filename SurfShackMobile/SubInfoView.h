//
//  SubInfoView.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 9/3/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateHandler.h" 
#import "SwellPacket.h"

@interface SubInfoView : UIView
{
    UILabel* titleLabel;
    UITextView* infoTextView;
}

-(void)updateInfoFromDict:(NSMutableDictionary*)spotDictInit forView:(int)viewTag;

@end