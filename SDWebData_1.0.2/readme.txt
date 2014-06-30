SDWebData

/*
 来自成都本土的程序员,
 热忱希望与大家一起交流IOS和MAC开发的心得，
 邮箱:tanhaogg@gmail.com
*/

历史版本：

SDWebData v1.0.2
更新:
1.SDWebDataManager的代理方法webDataManager:didFinishWithData:更新为webDataManager:didFinishWithData:isCache:,新增一个用以表示是否
为缓存数据的标识。
2.新增了SDNetworkActivityIndicator类,用于标识当前的网络状态。

SDWebData v1.0.1
更新:
1.修改了SDDataCache实例方法cleanDisk,因为原版的是当文件的更新时间等于某个特定的时间时就删除，
但是却没有考虑到如果文件刚好过期的当天没有使用软件则不能清除。
2.增加了当UIApplicationWillResignActiveNotification消息时执行cleanDisk，因为原版本中只有UIApplicationWillTerminateNotification
消息时才cleanDisk，但此消息在IOS4上不再适合了。

SDWebData v1.0.0
功能：
1.它是以SDWebImage为原型，改造成的对服务器返回的NSData对象的缓存技术。(SDWebImage只能对于NSImage或UIImage有效)；
2.同时也封装了一个SDImageView+SDWebCache，它是NSImageView或UIImageView的一个category,实现了异步加载和缓存技术。