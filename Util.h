//
//  Util.h
//  RasterPathCodingTask
//
//  Created by Peter Megyesi on 2015. 06. 26..
//  Copyright (c) 2015. petya. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const DIMENSION_STR;
FOUNDATION_EXPORT NSString *const WIDTH_STR;
FOUNDATION_EXPORT NSString *const START_X_STR;
FOUNDATION_EXPORT NSString *const START_Y_STR;
FOUNDATION_EXPORT NSString *const END_X_STR;
FOUNDATION_EXPORT NSString *const END_Y_STR;
FOUNDATION_EXPORT NSString *const WEIGHT_OPTION_STR;
FOUNDATION_EXPORT NSString *const PATH_STR;

typedef NS_ENUM(NSInteger, Octant_t) {
    octant_1 = 1,
    octant_2,
    octant_3,
    octant_4,
    octant_5,
    octant_6,
    octant_7,
    octant_8
};

/*!
 
 @class Util
 
 @brief Utility class mainly handling I/O and serving some consts and typdefs
 
 @helps RPPoint, main
 
 */
@interface Util : NSObject

/*
 @brief Handles initial user input on the console.
 @discussion Data input either manually (terminal) or from file.
 (File location is prompted in terminal.)
 @return A Dictionary of all the data necessary for the calculations (parsed from file or terminal).
 */
+ (NSDictionary *)runMainMenuInTerminal;

+ (int)getNumberFromUserWithFileHandle:(NSFileHandle*)fileHandle withMin:(int)minNumber;

+ (int)getNumberFromUserWithFileHandle:(NSFileHandle *)fileHandle withMin:(int)minNumber withMax:(int)maxNumber;

/*!
 @brief Asks (console) for output path and if weight option should be printed.
 @return Path and weightOption in a Dictionary
 */
+ (NSDictionary *)displayFarewellMsg;


@end
