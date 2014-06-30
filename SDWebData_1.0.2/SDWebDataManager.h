//
//  SDWebDataManager.h
//  SDWebData
//
//  Created by stm on 11-7-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDDataCache.h"
#import "SDWebDataDownloader.h"

@protocol SDWebDataManagerDelegate;
@interface SDWebDataManager : NSObject<SDDataCacheDelegate,SDWebDataDownloaderDelegate> {
	NSMutableArray *delegates;
    NSMutableArray *downloaders;
    NSMutableDictionary *downloaderForURL;
    NSMutableArray *failedURLs;
}

+ (id)sharedManager;
- (NSData *)dataWithURL:(NSURL *)url;

- (void)downloadWithURL:(NSURL *)url delegate:(id<SDWebDataManagerDelegate>)delegate;
- (void)downloadWithURL:(NSURL *)url delegate:(id<SDWebDataManagerDelegate>)delegate refreshCache:(BOOL)refreshCache;
- (void)downloadWithURL:(NSURL *)url delegate:(id<SDWebDataManagerDelegate>)delegate refreshCache:(BOOL)refreshCache retryFailed:(BOOL)retryFailed;
/**
 refreshCache=YES,重新下载并覆盖已有的cache;
 retryFailed=YES,失败后可以再次下载;
 lowPriority=YES,低优先级.
 **/
- (void)downloadWithURL:(NSURL *)url delegate:(id<SDWebDataManagerDelegate>)delegate refreshCache:(BOOL)refreshCache retryFailed:(BOOL)retryFailed lowPriority:(BOOL)lowPriority;
- (void)cancelForDelegate:(id<SDWebDataManagerDelegate>)delegate;

@end


@protocol SDWebDataManagerDelegate <NSObject>

@optional
- (void)webDataManager:(SDWebDataManager *)dataManager didFinishWithData:(NSData *)aData isCache:(BOOL)isCache;
- (void)webDataManager:(SDWebDataManager *)dataManager didFailWithError:(NSError *)error;

@end