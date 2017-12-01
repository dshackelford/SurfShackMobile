//
//  DBTableColumn.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/10/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBTableColumn : NSObject
{
    NSString* columnName;
    NSString* typeName;
    int columnNumber;
}

-(void) setColumnName :(NSString*)name;
-(void) setTypeName :(NSString*)name;
-(void) setColumnNumber :(int)number;

-(NSString*) getColumnName;
-(NSString*) getTypeName;
-(int) getColumnNumber;


@end
