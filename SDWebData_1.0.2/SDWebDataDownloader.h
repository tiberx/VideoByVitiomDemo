//
//  SDWebDataDownloader.h
//  SDWebData
//
//  Created by stm on 11-7-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const SDWebImageDownloadStartNotification;
extern NSString *const SDWebImageDownloadStopNotification;

@protocol SDWebDataDownloaderDelegate;
@interface SDWebDataDownloader : NSObject {
    @private
    NSURL *url;
    id<SDWebDataDownloaderDelegate> delegate;
    NSURLConnection *connection;
    NSMutableData *theData;
	id userInfo;
    BOOL lowPriority;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, assign) id<SDWebDataDownloaderDelegate> delegate;
@property (nonatomic, retain) NSMutableData *theData;
@property (nonatomic, retain) id userInfo;
@property (nonatomic, readwrite) BOOL lowPriority;

+ (id)downloaderWithURL:(NSURL *)aUrl delegate:(id<SDWebDataDownloaderDelegate>)aDelegate userInfo:(id)aUserInfo lowPriority:(BOOL)aLowPriority;
+ (id)downloaderWithURL:(NSURL *)aUrl delegate:(id<SDWebDataDownloaderDelegate>)aDelegate userInfo:(id)aUserInfo;
+ (id)downloaderWithURL:(NSURL *)aUrl delegate:(id<SDWebDataDownloaderDelegate>)aDelegate;
- (void)start;
- (void)cancel;

// This method is now no-op and is deprecated
+ (void)setMaxConcurrentDownloads:(NSUInteger)max __attribute__((deprecated));

@end

@protocol SDWebDataDownloaderDelegate <NSObject>

@optional
- (void)dataDownloaderDidFinish:(SDWebDataDownloader *)downloader;
- (void)dataDownloader:(SDWebDataDownloader *)downloader didFinishWithData:(NSData *)aData;
- (void)dataDownloader:(SDWebDataDownloader *)downloader didFailWithError:(NSError *)error;

@end