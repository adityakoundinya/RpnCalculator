//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Aditya Koundinya on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

-(void) pushOperand:(double)operand;
-(void) pushVariable:(NSString *)variables;
-(double) performOperation:(NSString *)operation;

@property (readonly) id program;

+(double) runProgram:(id)program;
+(double) runProgram:(id)program usingVariableValues: (NSDictionary *) variableValues;

+(NSString *) descriptionOfProgram:(id)program;
+(NSSet *)variablesUsedINProgram:(id)program;

-(NSString *) undoLastDigit;

-(void) clearOperandStack;
@end
