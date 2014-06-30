//
//  SDWebDataDownloader.m
//  SDWebData
//
//  Created by stm on 11-7-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SDWebDataDownloader.h"

NSString *const SDWebDataDownloadStartNotification = @"SDWebDataDownloadStartNotification";
NSString *const SDWebDataDownloadStopNotification = @"SDWebDataDownloadStopNotification";

@interface SDWebDataDownloader ()
@property (nonatomic, retain) NSURLConnection *connection;
@end

@implementation SDWebDataDownloader
@synthesize url, delegate, connection, theData, userInfo, lowPriority;

+ (id)downloaderWithURL:(NSURL *)aUrl delegate:(id<SDWebDataDownloaderDelegate>)aDelegate{
	return [[self class] downloaderWithURL:aUrl delegate:aDelegate userInfo:nil];
}

+ (id)downloaderWithURL:(NSURL *)aUrl delegate:(id<SDWebDataDownloaderDelegate>)aDelegate userInfo:(id)aUserInfo{
	return [[self class] downloaderWithURL:aUrl delegate:aDelegate userInfo:aUserInfo lowPriority:NO];
}

+ (id)downloaderWithURL:(NSURL *)aUrl delegate:(id<SDWebDataDownloaderDelegate>)aDelegate userInfo:(id)aUserInfo lowPriority:(BOOL)aLowPriority{
	// Bind SDNetworkActivityIndicator if available (download it here: http://github.com/rs/SDNetworkActivityIndicator )
    // To use it, just add #import "SDNetworkActivityIndicator.h" in addition to the SDWebImage import
    if (NSClassFromString(@"SDNetworkActivityIndicator"))
    {
        id activityIndicator = [NSClassFromString(@"SDNetworkActivityIndicator") performSelector:NSSelectorFromString(@"sharedActivityIndicator")];
        [[NSNotificationCenter defaultCenter] addObserver:activityIndicator
                                                 selector:NSSelectorFromString(@"startActivity")
                                                     name:SDWebDataDownloadStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:activityIndicator
                                                 selector:NSSelectorFromString(@"stopActivity")
                                                     name:SDWebDataDownloadStopNotification object:nil];
    }
    
    SDWebDataDownloader *downloader = [[[SDWebDataDownloader alloc] init] autorelease];
    downloader.url = aUrl;
    downloader.delegate = aDelegate;
    downloader.userInfo = aUserInfo;
    downloader.lowPriority = aLowPriority;
    [downloader performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:YES];
    return downloader;
}

+ (void)setMaxConcurrentDownloads:(NSUInteger)max
{
    // NOOP
}

- (void)start
{
    // In order to prevent from potential duplicate caching (NSURLCache + SDImageCache) we disable the cache for image requests
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO] autorelease];
	
    // If not in low priority mode, ensure we aren't blocked by UI manipulations (default runloop mode for NSURLConnection is NSEventTrackingRunLoopMode)
    if (!lowPriority)
    {
        [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
    [connection start];
    [request release];
	
    if (connection)
    {
        self.theData = [NSMutableData data];
        [[NSNotificationCenter defaultCenter] postNotificationName:SDWebDataDownloadStartNotification object:nil];
    }
    else
    {
        if ([delegate respondsToSelector:@selector(dataDownloader:didFailWithError:)])
        {
            [delegate performSelector:@selector(dataDownloader:didFailWithError:) withObject:self withObject:nil];
        }
    }
}

- (void)cancel
{
    if (connection)
    {
        [connection cancel];
        self.connection = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:SDWebDataDownloadStopNotification object:nil];
    }
}

#pragma mark NSURLConnection (delegate)

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data
{
    [theData appendData:data];
}

#pragma GCC diagnostic ignored "-Wundeclared-selector"
- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
    self.connection = nil;
	
    [[NSNotificationCenter defaultCenter] postNotificationName:SDWebDataDownloadStopNotification object:nil];
	
    if ([delegate respondsToSelector:@selector(dataDownloaderDidFinish:)])
    {
        [delegate performSelector:@selector(dataDownloaderDidFinish:) withObject:self];
    }
    
    if ([delegate respondsToSelector:@selector(dataDownloader:didFinishWithData:)])
    {
		NSData *data=[theData retain];
        [delegate performSelector:@selector(dataDownloader:didFinishWithData:) withObject:self withObject:data];
		[data release];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SDWebDataDownloadStopNotification object:nil];
	
    if ([delegate respondsToSelector:@selector(dataDownloader:didFailWithError:)])
    {
        [delegate performSelector:@selector(dataDownloader:didFailWithError:) withObject:self withObject:error];
    }
	
    self.connection = nil;
    self.theData = nil;
}

#pragma mark NSObject

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [url release], url = nil;
    [connection release], connection = nil;
    [theData release], theData = nil;
    [userInfo release], userInfo = nil;
    [super dealloc];
}

@end
