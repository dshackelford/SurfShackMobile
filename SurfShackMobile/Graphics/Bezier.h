//
//  Bezier.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/23/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIkit/UIKit.h>

@interface Bezier : NSObject
{
    
}

//"atPoint" is the center of the image
+(UIImageView*)draw:(UIBezierPath*)aPath inView:(UIView*)viewInit atPoint:(CGPoint)pointInit ofSize:(CGSize)sizeInit;
+(UIImageView*)drawColored:(UIBezierPath*)aPath inView:(UIView*)viewInit atPoint:(CGPoint)pointInit withColor:(UIColor*)colorInit ofSize:(CGSize)sizeInit;
@end