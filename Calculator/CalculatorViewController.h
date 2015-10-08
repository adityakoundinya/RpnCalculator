//
//  CalculatorViewController.h
//  Calculator
//
//  Created by Aditya Koundinya on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface CalculatorViewController : UIViewController<ADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UITextField *stack;
@property (weak, nonatomic) IBOutlet UILabel *variableDisplay;

@end
