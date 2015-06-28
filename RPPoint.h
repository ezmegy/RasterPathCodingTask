//
//  RPPoint.h
//  RasterPathCodingTask
//
//  Created by Peter Megyesi on 2015. 06. 26..
//  Copyright (c) 2015. petya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Util.h"

/*!
 
 @class RPPoint 
 
 @brief Representation of 2D coordinate pairs
 
 @discussion Besides (x,y) there is an additional weight member to represent 'half line pixels'
 
 */
@interface RPPoint : NSObject

@property (nonatomic) int x;
@property (nonatomic) int y;
@property (nonatomic) float weight;

- (instancetype)initWithX:(int)x withY:(int)y;
- (instancetype)initWithX:(int)x withY:(int)y withWeight:(float)w;
- (NSString *)toStringWithWeight:(BOOL)weightON;

- (void)transferPointToFirstOctantFromOctant:(Octant_t)fromOctant;
- (void)transferPointBackFromFirstOctantToOctant:(Octant_t)toOctant;

+ (Octant_t)getOctantForVectorWithStartPoint:(RPPoint *)p0 endPoint:(RPPoint *)p1;

+ (void)printAllRPPointsInSetToConsole:(NSSet*)set withWeight:(BOOL)weightON;
+ (void)writeAllRPPointsInSet:(NSSet*)set withWeight:(BOOL)weightON intoFile:(NSString*)filePath withInputDataFirst:(NSString*)inputData;

//deprecated
//+ (RPPoint *)wrapFixedPointInRPP:(FixedPoint)p;
//+ (FixedPoint)unwrapFixedPointFromRPP:(RPPoint*)p;
//+ (void)addFixedPoint:(FixedPoint)p toMutableSet:(NSMutableSet*)set;

@end
