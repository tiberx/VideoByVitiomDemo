//
//  UIImageView+SDWebCache.h
//  SDWebData
//
//  Created by stm on 11-7-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDWebImageCompatibly.h"
#import "SDWebDataManager.h"

@interface UIImageView(SDWebCacheCategory)<SDWebDataManagerDelegate>

- (void)setImageWithURL:(NSURL *)url;
- (void)setImageWithURL:(NSURL *)url refreshCache:(BOOL)refreshCache;
- (void)setImageWithURL:(NSURL *)url refreshCache:(BOOL)refreshCache placeholderImage:(UIImage *)placeholder;
- (void)cancelCurrentImageLoad;

@end
