//
//  PathCalculator.m
//  RasterPathCodingTask
//
//  Created by Peter Megyesi on 2015. 06. 26..
//  Copyright (c) 2015. petya. All rights reserved.
//

#import "PathCalculator.h"

extern int global_dimension;

@implementation PathCalculator

+ (NSSet*)runCalculationsWithParameters:(NSDictionary *)paramDict
{
    NSMutableSet *result = [[NSMutableSet alloc] init];
    
    if (paramDict) {
        
        RPPoint *startPoint = [[RPPoint alloc] initWithX:[[paramDict objectForKey:START_X_STR] intValue] withY:[[paramDict objectForKey:START_Y_STR] intValue]];
        RPPoint *endPoint = [[RPPoint alloc] initWithX:[[paramDict objectForKey:END_X_STR] intValue] withY:[[paramDict objectForKey:END_Y_STR] intValue]];
        int width = [[paramDict objectForKey:WIDTH_STR] intValue];
        
        [result setSet:[PathCalculator calcPixelsOnPathWithStartPoint:startPoint endPoint:endPoint lineWidth:width]];
    }
    else {
        NSLog(@"Error: parameters not available when running calculations!");
    }
    
    return result;
}

+ (NSSet *)calcPixelsOnPathWithStartPoint:(RPPoint *)p0 endPoint:(RPPoint *)p1 lineWidth:(int)width
{
    //determine Octant for the whole vector (==line==path)
    Octant_t originalOctant = [RPPoint getOctantForVectorWithStartPoint:p0 endPoint:p1];
    
    //transfer the 2 points (==coordinate pairs) of the vector
    [p0 transferPointToFirstOctantFromOctant:originalOctant];
    [p1 transferPointToFirstOctantFromOctant:originalOctant];
    
    //calculate every point on the vector which was transferred into the first octant - as the midPoint alg. needed it to be
    NSSet *firstOctantResulSet = [PathCalculator calcPointsWithMidPointLineAlgForVectorWithStartPoint:p0 endPoint:p1 lineWidth:width];
    
    //transfer the results back into the original octant
    NSMutableSet *originalOctantResultSet = [[NSMutableSet alloc] init];
    for (RPPoint *pixel in firstOctantResulSet) {
        
        [pixel transferPointBackFromFirstOctantToOctant:originalOctant];
        [originalOctantResultSet addObject:pixel];
    }
    
    return originalOctantResultSet;
}

+ (NSSet*)calcPointsWithMidPointLineAlgForVectorWithStartPoint:(RPPoint *)p0 endPoint:(RPPoint *)p1 lineWidth:(int)width
{
    NSMutableSet *pointsOnLine = [[NSMutableSet alloc] init];
    
    //Width's variables:
    //Odd width - normal mode, all pixels are equally weighted
    //Even width - the pixels on the two edge-lines are going to be weighted half
    BOOL bHalfLineEdgesON = false;
    if (width % 2 == 0) {
        bHalfLineEdgesON = true;
    }
    int additionInBothDirectionOnY = 0;
    if (bHalfLineEdgesON) {
        float halfValBeforeRounding = (width) / 2;
        additionInBothDirectionOnY = (int)(halfValBeforeRounding + 0.5);
    }
    else {
        float halfValBeforeRounding = (width - 1) / 2;
        additionInBothDirectionOnY = (int)(halfValBeforeRounding + 0.5);
    }
    
    //Midpoint Alg's variables
    int dx =  p1.x - p0.x;
    int dy =  p1.y - p0.y;
    
    int D = 2 * dy - dx;
    int incrementEast = 2 * dy;
    int incrementNorthEast = 2 * (dy - dx);
    
    //initial central line's pixel
    [pointsOnLine addObject:p0];
    
    //initial add-on lines' pixels if width > 1
    if (width > 1)
    {
        [PathCalculator extendPoint:p0 inBothDirectionsOnYBy:additionInBothDirectionOnY withHalfEdges:bHalfLineEdgesON andAddExtraPixelsToSet:pointsOnLine];
    }
    
    int y = p0.y;
    for (int x = p0.x + 1; x <= p1.x; ++x) {
        
        if (D > 0) {
            
            ++y;
            
            //central line's pixel
            RPPoint *newRPPoint = [[RPPoint alloc] initWithX:x withY:y];
            [pointsOnLine addObject:newRPPoint];
            
            //additional pixels according to line width
            [PathCalculator extendPoint:newRPPoint inBothDirectionsOnYBy:additionInBothDirectionOnY withHalfEdges:bHalfLineEdgesON andAddExtraPixelsToSet:pointsOnLine];
            
            D += incrementNorthEast;
        }
        else {
            
            //central line's pixel
            RPPoint *newRPPoint = [[RPPoint alloc] initWithX:x withY:y];
            [pointsOnLine addObject:newRPPoint];
            
            //additional pixels according to line width
            [PathCalculator extendPoint:newRPPoint inBothDirectionsOnYBy:additionInBothDirectionOnY withHalfEdges:bHalfLineEdgesON andAddExtraPixelsToSet:pointsOnLine];
            
            D += incrementEast;
        }
        
    }
    
    return pointsOnLine;
}

+ (void)extendPoint:(RPPoint *)originalPoint
inBothDirectionsOnYBy:(int)numOfExtraPixelsInBothDirections
      withHalfEdges:(BOOL)halfEdgeOn
andAddExtraPixelsToSet:(NSMutableSet *)set
{
    
    //even width
    if (halfEdgeOn) {
        
        //for each additional line
        for (int yTemp = 1; yTemp <= numOfExtraPixelsInBothDirections; ++yTemp) {
            
            //central lines (not one of the two on the edge)
            if (yTemp != numOfExtraPixelsInBothDirections) {
                
                ///** check + boundaries on Y axis
                if (originalPoint.y + yTemp <= global_dimension) {
                    RPPoint *additionalRPPointUp = [[RPPoint alloc] initWithX:originalPoint.x withY:(originalPoint.y + yTemp)];
                    [set addObject:additionalRPPointUp];
                }
                
                ///** check - boundaries on Y axis
                if (originalPoint.y - yTemp >= 0) {
                    RPPoint *additionalRPPointDown = [[RPPoint alloc] initWithX:originalPoint.x withY:(originalPoint.y - yTemp)];
                    [set addObject:additionalRPPointDown];
                }
                
            }
            //edges: init with only 0.5 weight
            else {
                
                ///** check + boundaries on Y axis
                if (originalPoint.y + yTemp <= global_dimension) {
                    RPPoint *additionalRPPointUp = [[RPPoint alloc] initWithX:originalPoint.x withY:(originalPoint.y + yTemp) withWeight:EDGE_WEIGHT];
                    [set addObject:additionalRPPointUp];
                }
                
                //** check - boundaries on Y axis
                if (originalPoint.y - yTemp >= 0) {
                    RPPoint *additionalRPPointDown = [[RPPoint alloc] initWithX:originalPoint.x withY:(originalPoint.y - yTemp) withWeight:EDGE_WEIGHT];
                    [set addObject:additionalRPPointDown];
                }

            }
        }//end for
    }
    //odd width
    else {
        
        //for each additional line
        for (int yTemp = 1; yTemp <= numOfExtraPixelsInBothDirections; ++yTemp) {
            
            //there are only 'central' lines here
            
            ///** check + boundaries on Y axis
            if (originalPoint.y + yTemp <= global_dimension) {
                RPPoint *additionalRPPointUp = [[RPPoint alloc] initWithX:originalPoint.x withY:(originalPoint.y + yTemp)];
                [set addObject:additionalRPPointUp];
            }
            
            //** check - boundaries on Y axis
            if (originalPoint.y - yTemp >= 0) {
                RPPoint *additionalRPPointDown = [[RPPoint alloc] initWithX:originalPoint.x withY:(originalPoint.y - yTemp)];
                [set addObject:additionalRPPointDown];
            }
            
        }
        
    }
}

@end
