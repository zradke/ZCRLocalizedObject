//
//  ZCRViewController.m
//  ZCRLocalizedObject
//
//  Created by Zach Radke on 09/03/2014.
//  Copyright (c) 2014 Zach Radke. All rights reserved.
//

#import "ZCRViewController.h"

#import <ZCRLocalizedObject/ZCRLocalizedObject.h>

@interface ZCRViewController ()

@property (weak, nonatomic) IBOutlet UILabel *localizedLabel;

@end

@implementation ZCRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *testData = @{@"en": @"Hello!",
                               @"fr": @"Bonjour!",
                               @"ja": @"こんにちは！",
                               @"de": @"Guten Tag!"};
    
    self.localizedLabel.text = (id)ZCRLocalize(testData);
}

@end
