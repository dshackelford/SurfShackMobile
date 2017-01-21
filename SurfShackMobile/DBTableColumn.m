//
//  DBTableColumn.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/10/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBTableColumn.h"

@implementation DBTableColumn

-(void) setColumnName :(NSString*)name
{
    columnName = [NSString stringWithString:name];
}

-(void) setTypeName :(NSString*)name
{
    typeName = [NSString stringWithString:name];
}

-(void) setColumnNumber :(int)number
{
    columnNumber = number;
}

-(NSString*) getColumnName
{
    return columnName;
}

-(NSString*) getTypeName
{
    return typeName;
}

-(int) getColumnNumber
{
    return columnNumber;
}

@end