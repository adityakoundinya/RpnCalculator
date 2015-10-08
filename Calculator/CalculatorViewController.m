//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Aditya Koundinya on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController() 

@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANUmber;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic, strong) NSDictionary *testVariableValues;
@property (nonatomic) BOOL bannerIsVisible;

-(void) displayProgram;
-(void) displayVariables;

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize stack = _stack;
@synthesize variableDisplay = _variableDisplay;
@synthesize userIsInTheMiddleOfEnteringANUmber = _userIsInTheMiddleOfEnteringANUmber;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;
@synthesize bannerIsVisible = _bannerIsVisible;

-(CalculatorBrain *) brain{
    if(!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    BOOL shouldExecuteAction = [self allowActionToRun]; // your application implements this method
    if (!willLeave && shouldExecuteAction)
    {
        // insert code here to suspend any services that might conflict with the advertisement
    }
    return shouldExecuteAction;
}

- (BOOL) allowActionToRun{
    return true;

}

- (IBAction)digitPressed:(UIButton *)sender {
    NSString *digit = sender.currentTitle;
    if(self.userIsInTheMiddleOfEnteringANUmber){
        if([digit isEqualToString:@"."]){
            if([self.display.text rangeOfString:@"."].location == NSNotFound){
                self.display.text = [self.display.text stringByAppendingFormat:@"%@",digit];
            }
        }else{
            self.display.text = [self.display.text stringByAppendingString:digit];
        }
    }else{
        self.display.text = digit;   
        self.userIsInTheMiddleOfEnteringANUmber = YES;
    }
}

- (IBAction)enterPressed {
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANUmber = NO;
    [self displayProgram];
}

- (IBAction)operationPressed:(UIButton *)sender {
    if(self.userIsInTheMiddleOfEnteringANUmber)[self enterPressed];
    NSString *operation = sender.currentTitle;
    double result = [self.brain performOperation:operation];
    self.display.text = [NSString stringWithFormat:@"%g",result];
    [self displayProgram];
}
- (IBAction)cancelPressed {
    self.display.text = @"0";
    self.stack.text = nil;
    self.variableDisplay.text = nil;
    [self.brain clearOperandStack];
}
- (void)deleteLastCharacter {
    if(self.userIsInTheMiddleOfEnteringANUmber){
        if([self.display.text length] > 1){
            self.display.text = [self.display.text substringToIndex:[self.display.text length] - 1];
        } else {
            self.display.text = @"0";
            self.userIsInTheMiddleOfEnteringANUmber = NO;
        }
    }
}

- (IBAction)backSpacePressed {
    [self deleteLastCharacter];
}
- (IBAction)changeSignPressed {
    if([self.display.text length] > 0){
          if([self.display.text rangeOfString: @"-"].location == NSNotFound){
            self.display.text = [@"-" stringByAppendingFormat:@"%@",self.display.text];
        }else{
            self.display.text = [self.display.text substringFromIndex:1];
        }
    }else{
        self.display.text = [@"-" stringByAppendingFormat:@"%@",self.display.text];
        self.userIsInTheMiddleOfEnteringANUmber = YES;
    }
}
- (IBAction)variablePressed:(UIButton *)sender {
    NSString *variable = sender.currentTitle;
    if(self.userIsInTheMiddleOfEnteringANUmber)[self enterPressed];
    [self.brain pushVariable:variable];
    [self displayProgram];
}
- (IBAction)test1Pressed {
    if(self.userIsInTheMiddleOfEnteringANUmber)[self enterPressed];
    self.testVariableValues = [[NSDictionary alloc]initWithObjectsAndKeys:@"3",@"x",@"4",@"y",@"0",@"foo", nil];
    double result = [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues];
    self.display.text = [NSString stringWithFormat:@"%g",result];
    [self displayProgram];
    [self displayVariables];
    
}
- (IBAction)test2Pressed {
        if(self.userIsInTheMiddleOfEnteringANUmber)[self enterPressed];
    self.testVariableValues = [[NSDictionary alloc]initWithObjectsAndKeys:@"-2",@"x",@"1000",@"y",@"9",@"foo", nil];
    double result = [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues];
    self.display.text = [NSString stringWithFormat:@"%g",result];
    [self displayProgram];
    [self displayVariables];
}
- (IBAction)test3Pressed {
        if(self.userIsInTheMiddleOfEnteringANUmber)[self enterPressed];
    self.testVariableValues = [[NSDictionary alloc]initWithObjectsAndKeys:@"56784",@"x",@"987354",@"y",@"-0.56874",@"foo", nil];
    double result = [CalculatorBrain runProgram:self.brain.program usingVariableValues:self.testVariableValues];
    self.display.text = [NSString stringWithFormat:@"%g",result];
    [self displayProgram];
    [self displayVariables];
}
- (IBAction)undoPressed {
    if(self.userIsInTheMiddleOfEnteringANUmber){
        [self deleteLastCharacter];
    }else{
        NSString *lastNumber = [self.brain undoLastDigit];
        self.display.text = lastNumber;
        [self displayProgram];
    }
}

- (void)viewDidUnload {
    [self setStack:nil];
    [self setVariableDisplay:nil];
    [super viewDidUnload];
}

- (void) displayProgram{
    self.stack.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
}
-(void) displayVariables{
    NSSet *variableSet = [CalculatorBrain variablesUsedINProgram:self.brain.program];
    if(!variableSet) return;
    if([variableSet count] <= 0) return;
    NSEnumerator *enumerator = [variableSet objectEnumerator];
    NSString *variables;
    id value;
    NSString *variableValue;
    while(value = [enumerator nextObject]){
        variableValue = value;
        variableValue = [variableValue stringByAppendingString:@" = "];
        variableValue = [variableValue stringByAppendingString:[self.testVariableValues valueForKey:value]];
        variableValue = [variableValue stringByAppendingString:@" "];
        if(variables){
            variables = [variables stringByAppendingString:variableValue];
        }else{
            variables = variableValue;
        }
    }
    self.variableDisplay.text = variables;
    
}
@end
