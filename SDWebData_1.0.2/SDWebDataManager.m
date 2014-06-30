//
//  SDWebDataManager.m
//  SDWebData
//
//  Created by stm on 11-7-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SDWebDataManager.h"

static SDWebDataManager *instance=nil;

@implementation SDWebDataManager

- (id)init
{
    if ((self = [super init]))
    {
        delegates = [[NSMutableArray alloc] init];
        downloaders = [[NSMutableArray alloc] init];
        downloaderForURL = [[NSMutableDictionary alloc] init];
        failedURLs = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [delegates release], delegates = nil;
    [downloaders release], downloaders = nil;
    [downloaderForURL release], downloaderForURL = nil;
    [failedURLs release], failedURLs = nil;
    [super dealloc];
}


+ (id)sharedManager
{
    if (instance == nil)
    {
        instance = [[SDWebDataManager alloc] init];
    }
	
    return instance;
}

/**
 * @deprecated
 */
- (NSData *)dataWithURL:(NSURL *)url
{
	return [[SDDataCache sharedDataCache] dataFromKey:[url absoluteString]];
}

- (void)downloadWithURL:(NSURL *)url delegate:(id<SDWebDataManagerDelegate>)delegate
{
	[self downloadWithURL:url delegate:delegate refreshCache:NO];
}

- (void)downloadWithURL:(NSURL *)url delegate:(id<SDWebDataManagerDelegate>)delegate refreshCache:(BOOL)refreshCache
{
	[self downloadWithURL:url delegate:delegate refreshCache:refreshCache retryFailed:NO];
}

- (void)downloadWithURL:(NSURL *)url delegate:(id<SDWebDataManagerDelegate>)delegate refreshCache:(BOOL)refreshCache retryFailed:(BOOL)retryFailed
{
	[self downloadWithURL:url delegate:delegate refreshCache:refreshCache retryFailed:retryFailed lowPriority:NO];
}

- (void)downloadWithURL:(NSURL *)url delegate:(id<SDWebDataManagerDelegate>)delegate refreshCache:(BOOL)refreshCache retryFailed:(BOOL)retryFailed lowPriority:(BOOL)lowPriority
{
	if (!url || !delegate || (!retryFailed && [failedURLs containsObject:url]))
    {
        return;
    }
    
	if (!refreshCache) 
	{
		// Check the on-disk cache async so we don't block the main thread
		NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:delegate, @"delegate", url, @"url", [NSNumber numberWithBool:lowPriority], @"low_priority", nil];
		[[SDDataCache sharedDataCache] queryDiskCacheForKey:[url absoluteString] delegate:self userInfo:info];
	}
	else {		
		// Share the same downloader for identical URLs so we don't download the same URL several times
		SDWebDataDownloader *downloader = [downloaderForURL objectForKey:url];
		
		if (!downloader) 
		{
			downloader = [SDWebDataDownloader downloaderWithURL:url delegate:self userInfo:nil lowPriority:lowPriority];
			[downloaderForURL setObject:downloader forKey:url];
		}
		
		// If we get a normal priority request, make sure to change type since downloader is shared
		if (!lowPriority && downloader.lowPriority)
			downloader.lowPriority = NO;
		
		[delegates addObject:delegate];
		[downloaders addObject:downloader];
	}

}

- (void)cancelForDelegate:(id<SDWebDataManagerDelegate>)delegate
{
	NSUInteger idx = [delegates indexOfObjectIdenticalTo:delegate];
	
    if (idx == NSNotFound)
    {
        return;
    }
	
	SDWebDataDownloader *downloader = [[downloaders objectAtIndex:idx] retain];
	
    [delegates removeObjectAtIndex:idx];
    [downloaders removeObjectAtIndex:idx];
	
    if (![downloaders containsObject:downloader])
    {
        // No more delegate are waiting for this download, cancel it
        [downloader cancel];
        [downloaderForURL removeObjectForKey:downloader.url];
    }
	
    [downloader release];
}

#pragma mark -
#pragma mark SDDataCacheDelegate

- (void)dataCache:(SDDataCache *)dataCache didFindData:(NSData *)aData forKey:(NSString *)key userInfo:(NSDictionary *)info
{
	id<SDWebDataManagerDelegate> delegate = [info objectForKey:@"delegate"];
	if ([delegate respondsToSelector:@selector(webDataManager:didFinishWithData:isCache:)])
	{
		[delegate webDataManager:self didFinishWithData:aData isCache:YES];
	}
}

- (void)dataCache:(SDDataCache *)dataCache didNotFindDataForKey:(NSString *)key userInfo:(NSDictionary *)info
{
	NSURL *url = [info objectForKey:@"url"];
	id<SDWebDataManagerDelegate> delegate = [info objectForKey:@"delegate"];
	BOOL lowPriority = [[info objectForKey:@"low_priority"] boolValue];
	
	// Share the same downloader for identical URLs so we don't download the same URL several times
	SDWebDataDownloader *downloader = [downloaderForURL objectForKey:url];
	
	if (!downloader) 
	{
		downloader = [SDWebDataDownloader downloaderWithURL:url delegate:self userInfo:nil lowPriority:lowPriority];
		[downloaderForURL setObject:downloader forKey:url];
	}
	
	// If we get a normal priority request, make sure to change type since downloader is shared
    if (!lowPriority && downloader.lowPriority)
        downloader.lowPriority = NO;
    
    [delegates addObject:delegate];
    [downloaders addObject:downloader];
}

#pragma mark -
#pragma mark SDWebDataDownloaderDelegate

- (void)dataDownloader:(SDWebDataDownloader *)downloader didFinishWithData:(NSData *)aData
{
	[downloader retain];
	
    // Notify all the delegates with this downloader
    for (NSInteger idx = [downloaders count] - 1; idx >= 0; idx--)
    {
        SDWebDataDownloader *aDownloader = [downloaders objectAtIndex:idx];
        if (aDownloader == downloader)
        {
            id<SDWebDataManagerDelegate> delegate = [delegates objectAtIndex:idx];
			
            if (aData)
            {
				if ([delegate respondsToSelector:@selector(webDataManager:didFinishWithData:isCache:)]) 
				{
					[delegate webDataManager:self didFinishWithData:aData isCache:NO];
				}
            }
            else
            {
				if ([delegate respondsToSelector:@selector(webDataManager:didFailWithError:)]) 
				{
					[delegate performSelector:@selector(webDataManager:didFailWithError:) withObject:self withObject:nil];
				}
            }
			
            [downloaders removeObjectAtIndex:idx];
            [delegates removeObjectAtIndex:idx];
        }
    }
	
    if (aData)
    {
        // Store the data in the cache
		[[SDDataCache sharedDataCache] storeData:aData
										  forKey:[downloader.url absoluteString]
										  toDisk:YES];
    }
    else
    {
        // The image can't be downloaded from this URL, mark the URL as failed so we won't try and fail again and again
        [failedURLs addObject:downloader.url];
    }
	
    // Release the downloader
    [downloaderForURL removeObjectForKey:downloader.url];
    [downloader release];
}

- (void)dataDownloader:(SDWebDataDownloader *)downloader didFailWithError:(NSError *)error
{
	[downloader retain];
	
    // Notify all the delegates with this downloader
    for (NSInteger idx = [downloaders count] - 1; idx >= 0; idx--)
    {
        SDWebDataDownloader *aDownloader = [downloaders objectAtIndex:idx];
        if (aDownloader == downloader)
        {
            id<SDWebDataManagerDelegate> delegate = [delegates objectAtIndex:idx];
			
			if ([delegate respondsToSelector:@selector(webDataManager:didFailWithError:)]) 
			{
				[delegate performSelector:@selector(webDataManager:didFailWithError:) withObject:self withObject:error];
			}
			
            [downloaders removeObjectAtIndex:idx];
            [delegates removeObjectAtIndex:idx];
        }
    }
	
    // Release the downloader
    [downloaderForURL removeObjectForKey:downloader.url];
    [downloader release];
}


@end
