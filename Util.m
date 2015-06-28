//
//  Util.m
//  RasterPathCodingTask
//
//  Created by Peter Megyesi on 2015. 06. 26..
//  Copyright (c) 2015. petya. All rights reserved.
//

#import "Util.h"

int global_dimension = 0;

@implementation Util

NSString *const DIMENSION_STR = @"DIMENSION";
NSString *const WIDTH_STR = @"WIDTH";
NSString *const START_X_STR = @"START_X";
NSString *const START_Y_STR = @"START_Y";
NSString *const END_X_STR = @"END_X";
NSString *const END_Y_STR = @"END_Y";
NSString *const WEIGHT_OPTION_STR = @"WEIGHT_OPTION";
NSString *const PATH_STR = @"PATH";

+ (NSDictionary*)runMainMenuInTerminal
{
    NSString *manualInputOption = @"1\n";
    NSString *fileInputOption = @"2\n";
    NSString *exitOption = @"e\n";
    BOOL bValidSettings = NO;
    
    while (!bValidSettings) {
        NSLog(@"\n\n*** Welcome to this short session of calculating pixels coordinates on a path ***\n************************ Choose your destiny (muhahha) *************************\n\n\t\tInput stuff manually\t-\t1\n\n\t\tRead stuff from file\t-\t2\n\n\t\texit\t\t\t\t\t-\te\n");
        
        NSFileHandle *inputHandle = [NSFileHandle fileHandleWithStandardInput];
        NSData *inputData = [inputHandle availableData];
        NSString *str = [[NSString alloc] initWithData:inputData encoding:NSUTF8StringEncoding];
        
        //EXIT
        if ([str isEqualToString:exitOption]) {
            bValidSettings = YES;
            NSLog(@"byez");
            break;
        }
        //MANUAL input
        else if ([str isEqualToString:manualInputOption]) {
            bValidSettings = YES;
            
            //line1 - grid dimension, min 1, INT_MAX
            NSLog(@"OK, let's see...\n\n Enter map (NxN) dimension (i.e. 128):\n");
            // coordinates start with 0 -> dimension = input dimension - 1
            global_dimension = ([Util getNumberFromUserWithFileHandle:inputHandle withMin:1 withMax:INT_MAX] - 1);
            
            //line2 - path width, min 1
            NSLog(@"\n\n Enter path width:\n");
            int pathWidth = [Util getNumberFromUserWithFileHandle:inputHandle withMin:1];

            //line3 - start point, min 0, max dimension
            // X coordinate
            NSLog(@"\n\n Enter start points X coordinate:\n");
            int startX = [Util getNumberFromUserWithFileHandle:inputHandle withMin:0 withMax:global_dimension];
            
            // Y coordinate
            NSLog(@"\n\n Enter start points Y coordinate:\n");
            int startY = [Util getNumberFromUserWithFileHandle:inputHandle withMin:0 withMax:global_dimension];
            
            //line4 - end point
            // X coordinate
            NSLog(@"\n\n Enter end points X coordinate:\n");
            int endX = [Util getNumberFromUserWithFileHandle:inputHandle withMin:0 withMax:global_dimension];
            
            // Y coordinate
            NSLog(@"\n\n Enter end points Y coordinate:\n");
            int endY = [Util getNumberFromUserWithFileHandle:inputHandle withMin:0 withMax:global_dimension];
            
            NSDictionary *manualSettings = @{
                                        DIMENSION_STR : [NSNumber numberWithInt:global_dimension],
                                        WIDTH_STR : [NSNumber numberWithInt:pathWidth],
                                        START_X_STR : [NSNumber numberWithInt:startX ],
                                        START_Y_STR : [NSNumber numberWithInt:startY],
                                        END_X_STR : [NSNumber numberWithInt:endX],
                                        END_Y_STR : [NSNumber numberWithInt:endY]
                                        };
            
            return manualSettings;
        }
        //FILE input
        else if ([str isEqualToString:fileInputOption]) {
            bValidSettings = YES;
            
            NSLog(@"\nOK, where is the file? type in full path, i.e. /Users/petya/Desktop/in.txt");
            
            //open path
            NSData *inputData = [inputHandle availableData];
            NSString *filePath = [[NSString alloc] initWithData:inputData encoding:NSUTF8StringEncoding];
            // there's a \n at the end...
            if ([filePath length] > 1) {
                filePath = [filePath substringToIndex:[filePath length] - 1];
            }
            
            //read whole txt
            NSString* fileContents =
            [NSString stringWithContentsOfFile:filePath
                                      encoding:NSUTF8StringEncoding error:nil];
            if (!fileContents) {
                NSLog(@"\nError, file not found! Please start over.\n");
                bValidSettings = NO;
                break;
            }
            
            //separate by new line
            NSArray* allLines = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            
            if (allLines.count < 4) {
                NSLog(@"\nError, not enough parameters in the file! Please start over.\n");
                bValidSettings = NO;
                break;
            }
            
            //parse each line
            NSMutableArray *parametersFromLines = [[NSMutableArray alloc] init];
            for (NSString *line in allLines) {
                
                // split by ':' if necessary
                NSArray* splitLine = [line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
                
                if (splitLine.count > 1) {
                    [parametersFromLines addObject:[splitLine objectAtIndex:1]];
                }
                else {
                    [parametersFromLines addObject:[splitLine objectAtIndex:0]];
                }
            
            }
            
            // split 3. and 4. parameter by ',' also, to get the coordinates separately
            NSArray *splitThirdLine = [[parametersFromLines objectAtIndex:2] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
            NSArray *splitFourthLine = [[parametersFromLines objectAtIndex:3] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
            // remove coordinate pairs (last two objects) and insert them separately to parameterArray
            [parametersFromLines removeObject:[parametersFromLines lastObject]];
            [parametersFromLines removeObject:[parametersFromLines lastObject]];
            [parametersFromLines addObject:[splitThirdLine firstObject]];
            [parametersFromLines addObject:[splitThirdLine objectAtIndex:1]];
            [parametersFromLines addObject:[splitFourthLine firstObject]];
            [parametersFromLines addObject:[splitFourthLine objectAtIndex:1]];
            
            // convert format and insert parameters in settingDictionary
            NSDictionary *fileSettings = @{
                                             DIMENSION_STR :
                                                 [NSNumber numberWithInt:[[parametersFromLines objectAtIndex:0] intValue]],
                                             WIDTH_STR :
                                                 [NSNumber numberWithInt:[[parametersFromLines objectAtIndex:1] intValue]],
                                             START_X_STR :
                                                 [NSNumber numberWithInt:[[parametersFromLines objectAtIndex:2] intValue]],
                                             START_Y_STR :
                                                 [NSNumber numberWithInt:[[parametersFromLines objectAtIndex:3] intValue]],
                                             END_X_STR :
                                                  [NSNumber numberWithInt:[[parametersFromLines objectAtIndex:4] intValue]],
                                             END_Y_STR :
                                                   [NSNumber numberWithInt:[[parametersFromLines objectAtIndex:5] intValue]]
                                             };
            
            return fileSettings;
        }
        else {
            NSLog(@"eeeeep - try again...");
        }
    }//end while
    
    return nil;
}

+ (int)getNumberFromUserWithFileHandle:(NSFileHandle *)fileHandle withMin:(int)minNumber
{
    BOOL bNumberEntered = NO;
    int retNumber = -1;
    while (!bNumberEntered) {
    
        NSData *inputData = [fileHandle availableData];
        NSString *str = [[NSString alloc] initWithData:inputData encoding:NSUTF8StringEncoding];
        
        retNumber = [str intValue];
        
        if (retNumber >= minNumber) {
            bNumberEntered = YES;
        }
        else {
            NSLog(@"not a valid number (can't be lower than %d)\n ...try again...\n", minNumber);
        }
    }
    
    return retNumber;
}

+ (int)getNumberFromUserWithFileHandle:(NSFileHandle *)fileHandle withMin:(int)minNumber withMax:(int)maxNumber
{
    BOOL bNumberEntered = NO;
    int retNumber = -1;
    while (!bNumberEntered) {
        
        NSData *inputData = [fileHandle availableData];
        NSString *str = [[NSString alloc] initWithData:inputData encoding:NSUTF8StringEncoding];
        
        retNumber = [str intValue];
        
        if (retNumber >= minNumber && retNumber <= maxNumber) {
            bNumberEntered = YES;
        }
        else {
            NSLog(@"not a valid number (can't be lower than %d AND higher than %d)\n ...try again...\n", minNumber, maxNumber);
        }
    }
    return retNumber;
}

+ (NSDictionary *)displayFarewellMsg
{
    NSLog(@"\nThank you. The results will be print on screen shortly.\n\nPlease type in the path to the output file (i.e. /Users/petya/Desktop ):\n");
    
    NSFileHandle *inputHandle = [NSFileHandle fileHandleWithStandardInput];
    NSData *inputData1 = [inputHandle availableData];
    NSString *outPath = [[NSString alloc] initWithData:inputData1 encoding:NSUTF8StringEncoding];
    //there's a \n at the end...
    if ([outPath length] > 1) {
        outPath = [outPath substringToIndex:[outPath length] - 1];
    }
    
    NSLog(@"\nOK, one more thing: should we display the weights of the coordinates?\n\npress:\n\t\tfor yes\t\t\t-\t\t1\n\t\tfor no\t\t\t-\t\t2\n\t\tjust exit\t\t-\t\tanything else");
    
    NSData *inputData2 = [inputHandle availableData];
    NSString *weightOnOrOff = [[NSString alloc] initWithData:inputData2 encoding:NSUTF8StringEncoding];
    
    NSDictionary *printOptions = @{ PATH_STR : outPath, WEIGHT_OPTION_STR : weightOnOrOff };
    
    return printOptions;
}

@end
