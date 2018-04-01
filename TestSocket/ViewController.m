//
//  ViewController.m
//  TestSocket
//
//  Created by Epic Lanka on 3/31/18.
//  Copyright © 2018 Epic Lanka. All rights reserved.
//

#import "ViewController.h"
#import "MySocketSingleton.h"

@interface ViewController ()<SomethingDelegate>
@property (weak, nonatomic) IBOutlet UITextField *inputField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [self initNetworkCommunication];
//    MySocketSingleton *mySoc = [[MySocketSingleton alloc] init];
    
    [MySocketSingleton initNetworkCommunicationUrl:@"localhost" port:8080];
    [MySocketSingleton sharedGlobals].delegate = self;
}

- (IBAction)onTapSendMessg:(id)sender {
    [MySocketSingleton sendString:_inputField.text];

    
}

-(void)something:(NSString *)something{
    NSLog(@"meesgae 123 : %@",something);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
