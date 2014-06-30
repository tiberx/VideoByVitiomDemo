//
//  SDDataCache.m
//  SDWebData
//
//  Created by stm on 11-7-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SDDataCache.h"
#import <CommonCrypto/CommonDigest.h>

static NSString* const kDataCacheDirectory=@"DataCache";
static NSInteger cacheMaxCacheAge = 60*60*24*7; // 1 week
static SDDataCache *instance;

@implementation SDDataCache

- (id)init
{
    if ((self = [super init]))
    {
        // Init the memory cache
        memCache = [[NSMutableDictionary alloc] init];
		
        // Init the disk cache
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        diskCachePath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:kDataCacheDirectory] retain];
		
        if (![[NSFileManager defaultManager] fileExistsAtPath:diskCachePath])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:NULL];
        }
		
        // Init the operation queue
        cacheInQueue = [[NSOperationQueue alloc] init];
        cacheInQueue.maxConcurrentOperationCount = 1;
        cacheOutQueue = [[NSOperationQueue alloc] init];
        cacheOutQueue.maxConcurrentOperationCount = 1;
#if !TARGET_OS_IPHONE
#else
        // Subscribe to app events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
		
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cleanDisk)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
		
#ifdef __IPHONE_4_0
        UIDevice *device = [UIDevice currentDevice];
        if ([device respondsToSelector:@selector(isMultitaskingSupported)] && device.multitaskingSupported)
        {
            // When in background, clean memory in order to have less chance to be killed
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(clearMemory)
                                                         name:UIApplicationDidEnterBackgroundNotification
                                                       object:nil];
        }
		
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cleanDisk)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
#endif
#endif
    }
	
    return self;
}

- (void)dealloc
{
    [memCache release], memCache = nil;
    [diskCachePath release], diskCachePath = nil;
    [cacheInQueue release], cacheInQueue = nil;
	
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [super dealloc];
}

#pragma mark SDDataCache (class methods)

+ (SDDataCache *)sharedDataCache
{
    if (instance == nil)
    {
        instance = [[SDDataCache alloc] init];
    }
	
    return instance;
}

#pragma mark SDDataCache (private)

- (NSString *)cachePathForKey:(NSString *)key
{
    const char *str = [key UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
	
    return [diskCachePath stringByAppendingPathComponent:filename];
}

- (void)storeKeyWithDataToDisk:(NSArray *)keyAndData
{
    // Can't use defaultManager another thread
    NSFileManager *fileManager = [[NSFileManager alloc] init];
	
    NSString *key = [keyAndData objectAtIndex:0];

	// If no data representation given, convert the UIImage in JPEG and store it
	// This trick is more CPU/memory intensive and doesn't preserve alpha channel
	NSData *data=[[self dataFromKey:key fromDisk:YES] retain];  // be thread safe with no lock
	if (data)
	{
		[fileManager createFileAtPath:[self cachePathForKey:key] contents:data attributes:nil];
		[data release];
	}
	
    [fileManager release];
}

- (void)notifyDelegate:(NSDictionary *)arguments
{
    NSString *key = [arguments objectForKey:@"key"];
    id <SDDataCacheDelegate> delegate = [arguments objectForKey:@"delegate"];
    NSDictionary *info = [arguments objectForKey:@"userInfo"];
    NSData *data = [arguments objectForKey:@"data"];
	
    if (data)
    {
        [memCache setObject:data forKey:key];
		
        if ([delegate respondsToSelector:@selector(dataCache:didFindData:forKey:userInfo:)])
        {
            [delegate dataCache:self didFindData:data forKey:key userInfo:info];
        }
    }
    else
    {
        if ([delegate respondsToSelector:@selector(dataCache:didNotFindDataForKey:userInfo:)])
        {
            [delegate dataCache:self didNotFindDataForKey:key userInfo:info];
        }
    }
}

- (void)queryDiskCacheOperation:(NSDictionary *)arguments
{
    NSString *key = [arguments objectForKey:@"key"];
    NSMutableDictionary *mutableArguments = [[arguments mutableCopy] autorelease];
	
	NSData *data=[[[NSData alloc] initWithContentsOfFile:[self cachePathForKey:key]] autorelease];
    if (data)
    {
        [mutableArguments setObject:data forKey:@"data"];
    }
	
    [self performSelectorOnMainThread:@selector(notifyDelegate:) withObject:mutableArguments waitUntilDone:NO];
}

#pragma mark DataCache

- (void)storeData:(NSData *)aData forKey:(NSString *)key
{
	[self storeData:aData forKey:key toDisk:YES];
}

- (void)storeData:(NSData *)aData forKey:(NSString *)key toDisk:(BOOL)toDisk
{
    if (!aData || !key)
    {
        return;
    }
	
    if (toDisk && !aData)
    {
        return;
    }
	
    [memCache setObject:aData forKey:key];
	
    if (toDisk)
    {
		NSArray *keyWithData = [NSArray arrayWithObjects:key, nil];
		
        [cacheInQueue addOperation:[[[NSInvocationOperation alloc] initWithTarget:self
                                                                         selector:@selector(storeKeyWithDataToDisk:)
                                                                           object:keyWithData] autorelease]];
    }
}

- (NSData *)dataFromKey:(NSString *)key
{
    return [self dataFromKey:key fromDisk:YES];
}

- (NSData *)dataFromKey:(NSString *)key fromDisk:(BOOL)fromDisk
{
    if (key == nil)
    {
        return nil;
    }
	
	NSData *data=[memCache objectForKey:key];
	
    if (!data && fromDisk)
    {
		data=[[[NSData alloc] initWithContentsOfFile:[self cachePathForKey:key]] autorelease];
        if (data)
        {
            [memCache setObject:data forKey:key];
        }
    }
	
    return data;
}

- (void)queryDiskCacheForKey:(NSString *)key delegate:(id <SDDataCacheDelegate>)delegate userInfo:(NSDictionary *)info
{
    if (!delegate)
    {
        return;
    }
	
    if (!key)
    {
        if ([delegate respondsToSelector:@selector(dataCache:didNotFindDataForKey:userInfo:)])
        {
            [delegate dataCache:self didNotFindDataForKey:key userInfo:info];
        }
        return;
    }
	
    // First check the in-memory cache...
	NSData *data=[memCache objectForKey:key];
	
    if (data)
    {
        // ...notify delegate immediately, no need to go async
        if ([delegate respondsToSelector:@selector(dataCache:didFindData:forKey:userInfo:)])
        {
            [delegate dataCache:self didFindData:data forKey:key userInfo:info];
        }
        return;
    }
	
    NSMutableDictionary *arguments = [NSMutableDictionary dictionaryWithCapacity:3];
    [arguments setObject:key forKey:@"key"];
    [arguments setObject:delegate forKey:@"delegate"];
    if (info)
    {
        [arguments setObject:info forKey:@"userInfo"];
    }
    [cacheOutQueue addOperation:[[[NSInvocationOperation alloc] initWithTarget:self selector:@selector(queryDiskCacheOperation:) object:arguments] autorelease]];
}

- (void)removeDataForKey:(NSString *)key
{
    if (key == nil)
    {
        return;
    }
	
    [memCache removeObjectForKey:key];
    [[NSFileManager defaultManager] removeItemAtPath:[self cachePathForKey:key] error:nil];
}

- (void)clearMemory
{
    [cacheInQueue cancelAllOperations]; // won't be able to complete
    [memCache removeAllObjects];
}

- (void)clearDisk
{
    [cacheInQueue cancelAllOperations];
    [[NSFileManager defaultManager] removeItemAtPath:diskCachePath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
}

- (void)cleanDisk
{
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-cacheMaxCacheAge];
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:diskCachePath];
    for (NSString *fileName in fileEnumerator)
    {
        NSString *filePath = [diskCachePath stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        //if ([[[attrs fileModificationDate] laterDate:expirationDate] isEqualToDate:expirationDate])
		if ([[attrs fileModificationDate] compare:expirationDate]==NSOrderedAscending)
        {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
}

@end
