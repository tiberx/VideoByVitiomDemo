//
//  xukangwenViewController.m
//  VideoByVitiomDemo
//
//  Created by zhengyu xu on 14-6-19.
//  Copyright (c) 2014年 smg. All rights reserved.
//

#import "xukangwenViewController.h"

@interface xukangwenViewController ()

@end

@implementation xukangwenViewController

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];
    
    _isFullScreen=false;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UILabel *titleTxt=[[UILabel alloc]initWithFrame:CGRectMake(20, 20, 280, 20)];
    
    titleTxt.text=@"Vitamio的播放器封装库";
    
    [self.view addSubview:titleTxt];
    
    [titleTxt release];
    
    /**
     配置Target链接参数
     
     选择 Build Settings | Linking | Other Linker Flags, 将该选项的 Debug/Release 键都配置为 -ObjC .
     
     http://media4.cnlive.com:8080/00/00/06/20/mp4/620.mp4
     
     
     */
    
    
    KKWVideoView *videoView=[[KKWVideoView alloc]initWithFrame:CGRectMake(10, 50, 300, 220) WithPlayUrl:@"http://media4.cnlive.com:8080/00/00/06/20/mp4/620.mp4" withTitle:@"美食天降" withBgImg:nil withShu:false withCache:true withImgUrl:@"http://www.tuicool.com/images/mobile/index.png"];
    

    
    
    videoView.delegate=self;
    
    [self.view addSubview:videoView];
    
    [videoView release];
    
}

#pragma mark - KKWVideoViewDelegate 

- (void)showFullScreen:(KKWVideoView*)VideoView withIsFullSceen:(bool)IsFullSceen{
//通过该代理，实现横向全屏幕的界面重新绘制，初始化withShu 设置为False有效果
    
    _isFullScreen=IsFullSceen;

    if(IsFullSceen){
    
        NSLog(@"FullScreen");
        
        
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            
            [[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:(id)UIInterfaceOrientationLandscapeRight];
            
        }
        
        [UIViewController attemptRotationToDeviceOrientation];//这行代码是关键
        
        UIApplication *application=[UIApplication sharedApplication];
        [application setStatusBarHidden:YES];

    
    }else{
    
       NSLog(@"Screen");
        
         [[UIDevice currentDevice] performSelector:NSSelectorFromString(@"setOrientation:") withObject:(id)UIInterfaceOrientationPortrait];
        
        UIApplication *application=[UIApplication sharedApplication];
        [application setStatusBarHidden:YES];

    
    }


}
 
 


#pragma mark - didReceiveMemoryWarning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc{

    [super dealloc];

}


#pragma mark - UIInterfaceOrientation
//旋转相关
//旋转相关
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{//IOS 6.0之前版本
    // return (interfaceOrientation == UIInterfaceOrientationPortrait);
    
    return NO;
    
}

-(BOOL)shouldAutorotate{
    //IOS 6 关闭
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    //IOS 6 方向
    
    if(_isFullScreen){
        
    return UIInterfaceOrientationMaskLandscapeRight;
        
    }else{
     return  UIInterfaceOrientationMaskPortrait;

    }
}



@end
