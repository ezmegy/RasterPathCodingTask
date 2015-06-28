//
//  PathCalculator.h
//  RasterPathCodingTask
//
//  Created by Peter Megyesi on 2015. 06. 26..
//  Copyright (c) 2015. petya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPPoint.h"

static const float EDGE_WEIGHT = 0.5;

/*!
 @class PathCalculator
 
 @brief Helper class to run the calculations on start-end point pairs 
    to determine which other points should be drawn on their line.
 
 @discussion The algorithm used to do the calculations is called Midpoint-line or Bresenham's.
    Start- and endpoints must be converted to have a steepness (m) of 0 < m < 1, a.k.a. to be in the first octant.
    Handling even line widths relies on point representations having a weight property.
 
 To run the calculations, simply call @c[PathCalculator runCalculationsWithParameters:dictionaryContainingStartEndpointAndLineData];
 */
@interface PathCalculator : NSObject

+ (NSSet*)runCalculationsWithParameters:(NSDictionary *)paramDict;

/*!
 
 @brief This method does the calculation of a path with any start and end coordinates.
 @discussion Transfers the coordinates into first octant (0 < steepness of path < 1),
 then runs the MidPointLine alg,
 and finally converts coordinates back to original octant.
 */
+ (NSSet*)calcPixelsOnPathWithStartPoint:(RPPoint*)p0 endPoint:(RPPoint*)p1 lineWidth:(int)width;

/*!
 @brief This method implements the MidPointLine Algorithm.
 @param p0 start RPPoint, must be in the first octant
 p1 end RPPoint, must be in the first octant
 */
+ (NSSet*)calcPointsWithMidPointLineAlgForVectorWithStartPoint:(RPPoint*)p0 endPoint:(RPPoint*)p1 lineWidth:(int)width;

/*!
 @brief Adds extra pixels according to line width on Y axis
 
 @remark
 !Note in connection with the checking boundaries part marked with ***
 (at every additional line, so both odd and even case for-loops):
 1) bounds exist currently, because the specification said so:
 positive coordinates only in the window, when the user inputs dimension
 2) currently we 'overlap' the start and endpoints in case of a line width > 1,
 there might be situations when this is not OK -> add the extra check here
 */
+ (void)extendPoint:(RPPoint *)originalPoint inBothDirectionsOnYBy:(int)numOfExtraPixelsInBothDirections withHalfEdges:(BOOL)halfEdgeOn andAddExtraPixelsToSet:(NSMutableSet *)set;


@end
