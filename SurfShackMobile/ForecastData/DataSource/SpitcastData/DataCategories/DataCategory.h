//
//  DataCategory.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 12/14/17.
//  Copyright © 2017 Dylan Shackelford. All rights reserved.
//

#ifndef DataCategory_h
#define DataCategory_h

#import <AsyncBlockOperation/AsyncBlockOperation.h>
#import "DataCollector.h"

@interface DataCategory : NSObject

@property NSString* _Nonnull urlStr;
@property (nullable) NSData* downloadedData;
@property AsyncBlockOperation* _Nonnull op;
@property id<DataCollector> collector;

-(id)initWithSpotID:(int)spotIDInit andSpotName:(NSString*)spotName andOp:(AsyncBlockOperation*)op andCollector:(id<DataCollector>)collectorInit;
-(id)initWithCounty:(NSString*)countyInit andOp:(AsyncBlockOperation*)op andCollector:(id<DataCollector>)collectorInit;


-(void)grabData;

-(NSMutableDictionary*)makeDictionaryForData:(NSMutableArray*)dataArrayInit ofTypeHeight:(BOOL)heightBool;
-(void)gotSomeData:(NSData*)dataInit;

@end

#endif /* DataCategory_h */
