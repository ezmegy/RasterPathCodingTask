//
//  main.m
//  RasterPathCodingTask
//
//  Created by Peter Megyesi on 2015. 06. 26..
//  Copyright (c) 2015. petya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PathCalculator.h"
#import "Util.h"

int main(int argc, const char * argv[]) {
    
    @autoreleasepool {
        
        //What to calculate?
        NSMutableDictionary *parametersForCalculation = [[NSMutableDictionary alloc] init];
        BOOL bGotTheData = NO;
        
        while (!bGotTheData) {
             [parametersForCalculation setValuesForKeysWithDictionary:[Util runMainMenuInTerminal]];
            
            if (parametersForCalculation.count > 0) {
                bGotTheData = YES;
            }
        }
        
        //Do the math
        NSSet *result = [PathCalculator runCalculationsWithParameters:parametersForCalculation];
        
        //How to display results?
        NSDictionary *displayOptions = [Util displayFarewellMsg];
        
        BOOL printWeight = YES; //print by default
        
        if ([[displayOptions objectForKey:WEIGHT_OPTION_STR] intValue] == 2) {
            printWeight = NO;
        }
        
        //Display
        [RPPoint printAllRPPointsInSetToConsole:result withWeight:printWeight];
        
        //Write to file
        // get static user input from original params
        NSString *firstFourLines = [[NSString alloc] initWithFormat:
                                    @"%d\n%d\n%d,%d\n%d,%d\n",
                                    [[parametersForCalculation objectForKey:DIMENSION_STR] intValue],
                                    [[parametersForCalculation objectForKey:WIDTH_STR] intValue],
                                    [[parametersForCalculation objectForKey:START_X_STR] intValue],
                                    [[parametersForCalculation objectForKey:START_Y_STR] intValue],
                                    [[parametersForCalculation objectForKey:END_X_STR] intValue],
                                    [[parametersForCalculation objectForKey:END_Y_STR] intValue]];
        
        // write input data + results
        [RPPoint writeAllRPPointsInSet:result withWeight:printWeight intoFile:[displayOptions objectForKey:PATH_STR] withInputDataFirst:firstFourLines];
        
    }//end autorelease
    
    return 0;
}
