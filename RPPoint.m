//
//  RPPoint.m
//  RasterPathCodingTask
//
//  Created by Peter Megyesi on 2015. 06. 26..
//  Copyright (c) 2015. petya. All rights reserved.
//

#import "RPPoint.h"

@implementation RPPoint

#pragma mark - member methods
#pragma mark -- init etc
- (instancetype)initWithX:(int)x withY:(int)y
{
    self = [super init];
    
    if (self) {
        _x = x;
        _y = y;
        _weight = 1.0;
    }
    
    return self;
}

- (instancetype)initWithX:(int)x withY:(int)y withWeight:(float)w
{
    self = [super init];
    
    if (self) {
        _x = x;
        _y = y;
        _weight = w;
    }
    
    return self;
}

- (BOOL)isEqualToRPPoint:(RPPoint *)object
{
    if (!object) {
        return NO;
    }
    
    if (object.x == self.x && object.y == self.y) {
        return YES;
    }
    else {
        return NO;
    }
}

- (NSString *)toStringWithWeight:(BOOL)weightON
{
    if (weightON){
        return [[NSString alloc] initWithFormat:@"(%d,%d - %.1f)", self.x, self.y, self.weight];
    }
    else {
        return [[NSString alloc] initWithFormat:@"(%d,%d)", self.x, self.y];
    }
}

#pragma mark -- overrides
//override isEqual and hash for the comparison in Sets
- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (!object || ![object isKindOfClass:[RPPoint class]]) {
        return NO;
    }
    
    return [self isEqualToRPPoint:object];
}

- (NSUInteger)hash
{
    return self.x ^ self.y;
}

#pragma mark -- transfer own coordinates between octants
- (void)transferPointToFirstOctantFromOctant:(Octant_t)fromOctant
{
    //make copies first, weight stays the same
    int x = self.x;
    int y = self.y;
    
    switch (fromOctant) {
            //x,y
        case octant_1:
            break;
            
        case octant_2:
            self.x = y;
            self.y = x;
            break;
            
        case octant_3:
            self.x = y;
            self.y = -x;
            break;
            
        case octant_4:
            self.x = -x;
            self.y = y;
            break;
            
        case octant_5:
            self.x = -x;
            self.y = -y;
            break;
            
        case octant_6:
            self.x = -y;
            self.y = -x;
            break;
            
        case octant_7:
            self.x = -y;
            self.y = x;
            break;
            
        case octant_8:
            self.x = x;
            self.y = -y;
            break;
            
        default:
            break;
    }
}

- (void)transferPointBackFromFirstOctantToOctant:(Octant_t)toOctant
{
    //make copies first, weight stays the same
    int x = self.x;
    int y = self.y;
    
    switch (toOctant) {
            //x,y
        case octant_1:
            break;
            
        case octant_2:
            self.x = y;
            self.y = x;
            break;
            
            //-y,x !differs from toFirstOctant
        case octant_3:
            self.x = -y;
            self.y = x;
            break;
            
        case octant_4:
            self.x = -x;
            self.y = y;
            break;
            
        case octant_5:
            self.x = -x;
            self.y = -y;
            break;
            
        case octant_6:
            self.x = -y;
            self.y = -x;
            break;
            
            //y,-x !differs from toFirstOctant
        case octant_7:
            self.x = y;
            self.y = -x;
            break;
            
        case octant_8:
            self.x = x;
            self.y = -y;
            break;
            
        default:
            break;
    }

}

#pragma mark - Class methods
#pragma mark -- calculation with Octants
+ (Octant_t)getOctantForVectorWithStartPoint:(RPPoint *)p0 endPoint:(RPPoint *)p1
{
    /* octants:
     *
     *   \3|2/
     *   4\|/1
     *  ---+---
     *   5/|\8
     *   /6|7\
     */
    
    int nx = p1.x - p0.x;
    int ny = p1.y - p0.y;
    
    //first half +y
    if (0 < ny) {
        
        //first quadrant +x/+y
        if (0 < nx) {
            
            //first octant
            if (ny <= nx) {
                return octant_1;
            }
            //second octant
            else {
                return octant_2;
            }
        }
        //second quadrant -x/+y
        else {
            
            //third octant
            if (abs(nx) <= ny) {
                return octant_3;
            }
            //fourth octant
            else {
                return octant_4;
            }
        }
    }
    //second half -y
    else {
        //third quadrant  -x/-y
        if (0 > nx) {
            
            //fifth octant
            if (abs(ny) <= abs(nx)) {
                return octant_5;
            }
            //sixth octant
            else {
                return octant_6;
            }
        }
        //fourth quadrant  +x/-y
        else {
            
            //seventh octant
            if (nx <= abs(ny)) {
                return octant_7;
            }
            //eighth octant
            else {
                return octant_8;
            }
        }
    }
}

#pragma mark -- I/O
+ (void)printAllRPPointsInSetToConsole:(NSSet *)set withWeight:(BOOL)weightON
{
    NSArray *unsortedArr = [set allObjects];
    
    NSSortDescriptor *sdX = [[NSSortDescriptor alloc] initWithKey:@"x" ascending:YES];
    NSSortDescriptor *sdY = [[NSSortDescriptor alloc] initWithKey:@"y" ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sdX, sdY, nil];
    NSArray *sortedArray = [unsortedArr sortedArrayUsingDescriptors:sortDescriptors];
    
    for (RPPoint *p in sortedArray) {
        if (weightON) {
            NSLog(@"(%d,%d - %.1f) ", p.x, p.y, p.weight);
        }
        else {
            NSLog(@"(%d,%d) ", p.x, p.y);
        }
    }
}

+ (void)writeAllRPPointsInSet:(NSSet *)set withWeight:(BOOL)weightON intoFile:(NSString *)filePath withInputDataFirst:(NSString *)inputData
{
    //try to open directory
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL isDir;
    BOOL exists = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    
    if (!exists) {
        NSLog(@"Error, path to output file is not valid!");
    }
    else {
        
        //sort
        NSArray *unsortedArr = [set allObjects];
        
        NSSortDescriptor *sdX = [[NSSortDescriptor alloc] initWithKey:@"x" ascending:YES];
        NSSortDescriptor *sdY = [[NSSortDescriptor alloc] initWithKey:@"y" ascending:YES];
        
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sdX, sdY, nil];
        NSArray *sortedArray = [unsortedArr sortedArrayUsingDescriptors:sortDescriptors];
        
        if (isDir) {
            
            NSMutableString *filePathExtended = [[NSMutableString alloc] initWithString:filePath];
            
            //append out.txt
            char lastChar = [filePath characterAtIndex:[filePath length] - 1];
            if (lastChar == '/'){
                [filePathExtended appendString:@"out.txt"];
            }
            else {
                 [filePathExtended appendString:@"/out.txt"];
            }
            
            //create file
            [fileManager createFileAtPath:filePathExtended contents:nil attributes:nil];
            
            //create contentstring to flush at once - @param:input data + calculated points
            NSMutableString *allCalculatedPoints = [[NSMutableString alloc] init];
            for (RPPoint *p in sortedArray) {
                [allCalculatedPoints appendFormat:@"%@\n", [p toStringWithWeight:weightON]];
            }
            
            NSString *contentsToWrite = [[NSString alloc] initWithFormat:
                                         @"%@%@",
                                         inputData,
                                         allCalculatedPoints];
            // write into the new file
            [contentsToWrite writeToFile:filePathExtended atomically:YES encoding:NSUTF8StringEncoding error:NULL];
            
        }
    }

}

///deprecated
/*
 + (FixedPoint)unwrapFixedPointFromRPP:(RPPoint *)p
 {
 FixedPoint fp;
 fp.x = p.x;
 fp.y = p.y;
 
 return fp;
 }
 
 + (RPPoint *)wrapFixedPointInRPP:(FixedPoint)p
 {
 return [[RPPoint alloc] initWithX:p.x withY:p.y];
 }
 
 + (void)addFixedPoint:(FixedPoint)p toMutableSet:(NSMutableSet *)set
 {
 RPPoint *wrappedPoint = [RPPoint wrapFixedPointInRPP:p];
 [set addObject:wrappedPoint];
 }
 */

@end
