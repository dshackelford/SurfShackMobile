//
//  Bezier.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/23/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bezier.h"

@implementation Bezier

+(UIImageView*)draw:(UIBezierPath*)aPath inView:(UIView*)viewInit atPoint:(CGPoint)pointInit ofSize:(CGSize)sizeInit
{
    UIGraphicsBeginImageContextWithOptions(sizeInit, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);

    aPath.lineWidth = 5;
    
    [aPath stroke];
    
    UIImage *bezierImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    //make the image view from the path drawn on the context
    UIImageView* bezierImageView = [[UIImageView alloc]initWithImage:bezierImage];
    
    bezierImageView.center = CGPointMake(pointInit.x ,pointInit.y);
    
    return bezierImageView;
}

+(UIImageView*)drawColored:(UIBezierPath*)aPath inView:(UIView*)viewInit atPoint:(CGPoint)pointInit withColor:(UIColor*)colorInit ofSize:(CGSize)sizeInit
{
    UIGraphicsBeginImageContextWithOptions(sizeInit, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);
    
    
    CGContextSetFillColorWithColor(context, colorInit.CGColor);
    
    [aPath fill];
    
    UIImage *bezierImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    //make the image view from the path drawn on the context
    UIImageView* bezierImageView = [[UIImageView alloc]initWithImage:bezierImage];
    
    //the center is offset to accomodate the actual origin which will be used later for touch detection
    bezierImageView.center = CGPointMake(pointInit.x,pointInit.y);
    
    return bezierImageView;
}


@end