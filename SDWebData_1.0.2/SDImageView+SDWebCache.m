//
//  UIImageView+SDWebCache.m
//  SDWebData
//
//  Created by stm on 11-7-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SDImageView+SDWebCache.h"

@implementation UIImageView(SDWebCacheCategory)



int _Anmition_i=0;
bool isAnmiationFlag00=false;


- (void)setImageWithURL:(NSURL *)url
{
	[self setImageWithURL:url refreshCache:NO];
}

- (void)setImageWithURL:(NSURL *)url refreshCache:(BOOL)refreshCache
{
	[self setImageWithURL:url refreshCache:refreshCache placeholderImage:nil];
}

- (void)setImageWithURL:(NSURL *)url refreshCache:(BOOL)refreshCache placeholderImage:(UIImage *)placeholder
{
    SDWebDataManager *manager = [SDWebDataManager sharedManager];
	
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    
    
    
    self.image = placeholder;
    
    
   	
    if (url)
    {
        [manager downloadWithURL:url delegate:self refreshCache:refreshCache];
    }
    
}

- (void)setImageWithURL3:(NSURL *)url refreshCache:(BOOL)refreshCache placeholderImage:(UIImage *)placeholder
{
    SDWebDataManager *manager = [SDWebDataManager sharedManager];
	
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    
    //zhuye_bj.jpg
	
    
    
    self.image = placeholder;
    
    
    //----
    /**
    //http://blog.chukong-inc.com/index.php/2012/02/13/uiimageview%E7%9A%84animationimages%EF%BC%8C%E4%B8%8D%E7%BB%99%E5%8A%9B%E5%95%8A/
     之后我们考虑了自己去实现UIImageView的animation效果，题目之所以说他不给力，因为UIImageView的animation不会边用边释放(当然这点仅是我自己的拙见)，那就导致了如果图片很多，animation直接崩掉根本用不了
     
   http://lfhzxl.blog.51cto.com/5880209/985759
     
     UIImageView做帧动画内存问题，内存消耗太大。如果使用gif格式图片，会降低内存消耗，可是图片失真。今从网上看到一个帖子有更好方法解决，特意转载。
     
    */
    /**
    self.animationImages=[NSArray arrayWithObjects:[UIImage imageNamed:@"l1.png"],[UIImage imageNamed:@"l2.png"],[UIImage imageNamed:@"l3.png"],[UIImage imageNamed:@"l4.png"],[UIImage imageNamed:@"l5.png"],[UIImage imageNamed:@"l6.png"],[UIImage imageNamed:@"l7.png"],[UIImage imageNamed:@"l8.png"], nil];
     self.animationDuration=1;
     self.animationRepeatCount=8;
    [self startAnimating];
    */
    
    _Anmition_i=0;
    isAnmiationFlag00=true;
    [self performSelector:@selector(setNextImage) withObject:nil afterDelay:0.16];
    //----
	
    if (url)
    {
        [manager downloadWithURL:url delegate:self refreshCache:refreshCache];
    }
}

-(void)setNextImage
{
 
    if(!isAnmiationFlag00){
        return;
    }
    
    
    _Anmition_i++;
    
    if(_Anmition_i>8){
        _Anmition_i=1;
    }
    
    self.image = [UIImage imageNamed:[NSString stringWithFormat:@"l%i.png",_Anmition_i]];
    
    if(isAnmiationFlag00){
     [self performSelector:@selector(setNextImage) withObject:nil afterDelay:0.16];
    }else{
        return;
    }
    
    
}
- (void)setImageWithURL2:(NSURL *)url refreshCache:(BOOL)refreshCache placeholderImage:(UIImage *)placeholder
{
    SDWebDataManager *manager = [SDWebDataManager sharedManager];
	
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    
        
    
    self.image = placeholder;
    
    
   	
    if (url)
    {
        [manager downloadWithURL:url delegate:self refreshCache:refreshCache];
    }
}

- (void)cancelCurrentImageLoad
{
    [[SDWebDataManager sharedManager] cancelForDelegate:self];
}

#pragma mark -
#pragma mark SDWebDataManagerDelegate

- (void)webDataManager:(SDWebDataManager *)dataManager didFinishWithData:(NSData *)aData isCache:(BOOL)isCache
{
	 isAnmiationFlag00=false;
    
    UIImage *img=[UIImage imageWithData:aData];
    self.image=img;
}

@end
