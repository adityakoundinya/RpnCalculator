//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Aditya Koundinya on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic,strong) NSMutableArray *programStack;
@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

- (NSMutableArray *) programStack{
    if(_programStack == nil){
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

- (id) program{
    return [self.programStack copy];
}

+(NSString *) descriptionOfProgram:(id)program{
    // Check program is valid and if not return message
    if (![program isKindOfClass:([NSArray class])]) return @"Invalid program!";
    
    NSMutableArray *stack= [program mutableCopy];
    NSMutableArray *expressionArray = [NSMutableArray array];
    
    // Call recursive method to describe the stack, removing superfluous brackets at the
    // start and end of the resulting expression. Add the result into an expression array
    // and continue if there are still more items in the stack. 
    // our description Array, and if the 
    while (stack.count > 0) {
        [expressionArray addObject:[self deBracket:[self descriptionOffTopOfStack:stack]]];
    }
    
    // Return a list of comma seperated programs
    return [expressionArray componentsJoinedByString:@","];      }

+(NSSet *) variablesUsedINProgram:(id)program{
    NSMutableSet *variables = nil;
    for (id i in program) {
        if([i isKindOfClass:[NSString class]]){
            NSString *variable = i;
            if(![CalculatorBrain isOperation:i]){
                if(!variables) variables = [[NSMutableSet alloc]init];
                [variables addObject:variable];
            }
        }
    }
    return [variables copy];
}

+(double) popOperandOffStack:(NSMutableArray *) stack{
    double result = 0;
    id topOfStack = [stack lastObject];
    if(topOfStack) [stack removeLastObject];
    
    if([topOfStack isKindOfClass:[NSNumber class]]){
        return [topOfStack doubleValue];
    } else if([topOfStack isKindOfClass:[NSString class]]){
        NSString *operation = topOfStack;
        if([operation isEqualToString:@"+"]){
            result = [self popOperandOffStack:stack] + [self popOperandOffStack:stack];
        }else if([@"*" isEqualToString:operation]){
            result = [self popOperandOffStack:stack] * [self popOperandOffStack:stack];
        }else if([@"/" isEqualToString:operation]){
            double divisor = [self popOperandOffStack:stack];
            if(divisor){
                result = [self popOperandOffStack:stack] / divisor;
            }
        }else if([@"-" isEqualToString:operation]){
            double subtrahend = [self popOperandOffStack:stack];
            result = [self popOperandOffStack:stack] - subtrahend;
        }else if([@"sin" isEqualToString:operation]){
            result = sin([self popOperandOffStack:stack]);
        }else if([@"cos" isEqualToString:operation]){
            result = cos([self popOperandOffStack:stack]);
        }else if([@"sqrt" isEqualToString:operation]){
            result = sqrt([self popOperandOffStack:stack]);
        }else if([@"π" isEqualToString:operation]){
            result = M_PI;
        }
    }
    return result;
}

+ (NSString *)descriptionOffTopOfStack:(NSMutableArray *)stack {
    
    NSString *description;
    
    // Retrieve and remove the object at the top of the stack 
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject]; else return @"";
    
    // If the top of stack is an NSNumber then just return it as a NSString
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        return [topOfStack description];
    }       
    // but if it's an NSString we need to do some formatting
    else if ([topOfStack isKindOfClass:[NSString class]]) { 
        // If top of stack is a no operand operation, or it's a variable then we
        // want to return description in the form "x"
        if (![self isOperation:topOfStack] ||
            [self isNoOperation:topOfStack]) {  
            description = topOfStack;
        } 
        // If the top of stack is one operand operation, then we want to return an
        // expression in the form "f(x)"
        else if ([self isSingleOperation:topOfStack]) {
            // We need to remove any outside brackets on the recursive description
            // because we are going to put some new brackets on.
            NSString *x = [self deBracket:[self descriptionOffTopOfStack:stack]];
            description = [NSString stringWithFormat:@"%@(%@)", topOfStack, x]; 
        }
        // If the top of stack is a two operand operation then we want to return
        // an expression in the form "x op. y".
        else if ([self isTwoOperation:topOfStack]) {
            NSString *y = [self descriptionOffTopOfStack:stack];
            NSString *x = [self descriptionOffTopOfStack:stack];
            
            // If the top of stack is For + and - we need to add brackets so that
            // we support precedence rules.  
            if ([topOfStack isEqualToString:@"+"] || 
                [topOfStack isEqualToString:@"-"]) {               
                // String any existing brackets, before re-adding
                description = [NSString stringWithFormat:@"(%@ %@ %@)",
                               [self deBracket:x], topOfStack, [self deBracket:y]];
            } 
            // Otherwise, we are dealing with * or / so no need for brackets
            else {
                description = [NSString stringWithFormat:@"%@ %@ %@",
                               x, topOfStack ,y];
            }
        }       
    }
    return description ;  
}
+ (NSString *)deBracket:(NSString *)expression {
    
    NSString *description = expression;
    
    // Check to see if there is a bracket at the start and end of the expression
    // If so, then strip the description of these brackets and return.
    if ([expression hasPrefix:@"("] && [expression hasSuffix:@")"]) {
        description = [description substringFromIndex:1];
        description = [description substringToIndex:[description length] - 1];
    }   
    
    // Also need to do a final check, to cover the case where removing the brackets
    // results in a + b) * (c + d. Have a look at the position of the brackets and
    // if there is a ) before a (, then we need to revert back to expression
    NSRange openBracket = [description rangeOfString:@"("];
    NSRange closeBracket = [description rangeOfString:@")"];
    
    if (openBracket.location <= closeBracket.location) return description;
    else return expression; 
}
+(double) runProgram:(id)program{
    NSMutableArray *stack;
    if([program isKindOfClass:[NSArray class]]){
        stack = [program mutableCopy];
    }
    return [self popOperandOffStack:stack];
}

+(double) runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues{
    NSMutableArray *stack;
    if([program isKindOfClass:[NSArray class]]){
        stack = [program mutableCopy];
    }
    for(int i = 0; i<[stack count]; i++){
        id topOfStack = [stack objectAtIndex:i];
        if([topOfStack isKindOfClass:[NSString class]]){
            if(![CalculatorBrain isOperation:topOfStack]){
                double variableValue = 0;
                variableValue = [[variableValues valueForKey:topOfStack] doubleValue];
                [stack replaceObjectAtIndex:i withObject:[NSNumber numberWithDouble:variableValue]];
            }
        }
        
    }
    return [self popOperandOffStack:stack];
}
-(void) pushOperand:(double) operand{
    [self.programStack addObject:[NSNumber numberWithDouble:operand]];
}
-(void) pushVariable:(NSString *)variable{
    if(![CalculatorBrain isOperation:variable]){
        [self.programStack addObject:variable];
    }
}

-(double) performOperation:(NSString *)operation{
    
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program];
    
}

-(void) clearOperandStack{
    [self.programStack removeAllObjects];
}

+(bool) isOperation:(NSString *)operation{
    if([operation isEqualToString: @"sqrt"] || [operation isEqualToString: @"sin"] || [operation isEqualToString: @"cos"] || [operation isEqualToString: @"π"] ||
       [operation isEqualToString: @"+"] || [operation isEqualToString: @"-"] || [operation isEqualToString: @"*"] || [operation isEqualToString: @"/"]){
        return true;
    }
    return false;
}
+(bool) isTwoOperation:(NSString *)operation{
    if([operation isEqualToString: @"+"] || [operation isEqualToString: @"-"] || [operation isEqualToString: @"*"] || [operation isEqualToString: @"/"]){
        return true;
    }
    return false;
}
+(bool) isSingleOperation:(NSString *)operation{
    if([operation isEqualToString: @"sqrt"] || [operation isEqualToString: @"sin"] || [operation isEqualToString: @"cos"]){
        return true;
    }
    return false;
}
+(bool) isNoOperation:(NSString *)operation{
    if([operation isEqualToString: @"π"]){
        return true;
    }
    return false;
}
-(NSString *)undoLastDigit{
    NSString *previousNumber;
    id topOfStack = [self.programStack lastObject];
    if(topOfStack) [self.programStack removeLastObject];
    topOfStack = [self.programStack lastObject];
    if(topOfStack){ 
        if([topOfStack isKindOfClass:[NSNumber class]]){
            previousNumber = [NSString stringWithFormat:@"%g",[topOfStack doubleValue]];
        }
    }else {
        previousNumber = @"0";
    }
    return previousNumber;
}



@end
