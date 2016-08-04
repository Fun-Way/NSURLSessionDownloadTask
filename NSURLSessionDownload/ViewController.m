#import "ViewController.h"
#import "RainbowProgress.h"
#define MP4_URLString @"http://120.25.226.186:32812/resources/videos/minion_02.mp4"
@interface ViewController () <NSURLSessionDownloadDelegate>
/** 彩虹进度条 */
@property (nonatomic,weak)RainbowProgress *progress;
/** 下载任务 */
@property (nonatomic,strong)NSURLSessionDownloadTask *downloadTask;
/** 下载的数据信息 */
@property (nonatomic,strong)NSData *resumeData;
/** 下载的会话 */
@property (nonatomic,strong)NSURLSession *URLSession;
@end

@implementation ViewController
-(void)viewDidLoad{
    RainbowProgress* progress = [[RainbowProgress alloc] init];
    [progress startAnimating];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:progress];
    self.progress = progress;
    [self download];
}
#pragma mark - 创建会话的方法
-(void)download{
    // 创建会话
    self.URLSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration
            defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    // 确定URL
    NSURL* url = [NSURL URLWithString:MP4_URLString];
    // 通过会话在确定的URL上创建下载任务
    self.downloadTask = [self.URLSession downloadTaskWithURL:url];
    
}
#pragma mark - 按钮监听的点击事件方法
// 开始下载
- (IBAction)startDownload:(UIButton *)sender {
    // 启动任务
    [self.downloadTask resume];
} 
// 取消下载
- (IBAction)suspentDownload:(UIButton *)sender {
//    [self.downloadTask suspend];suspend暂停下载|可恢复的
    //cancelByProducingResumeData取消下载，同时可以获取已经下载的数据相关信息
    [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        self.resumeData = resumeData;
    }];
    NSLog(@"%s -- %@",__FUNCTION__,self.downloadTask);
}
// 继续下载
- (IBAction)goOnDownload:(UIButton *)sender {
    NSURLSessionDownloadTask* downloadTask = [self.URLSession downloadTaskWithResumeData:self.resumeData];
    [downloadTask resume];
    self.downloadTask = downloadTask;
}
#pragma mark - NSURLSessionDataDelegate Function
// 下载了数据的过程中会调用的代理方法
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten
    totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    NSLog(@"%lf",1.0 * totalBytesWritten / totalBytesExpectedToWrite);
    self.progress.progressValue = 1.0 * totalBytesWritten / totalBytesExpectedToWrite;
}
// 重新恢复下载的代理方法
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
    didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
}
// 写入数据到本地的时候会调用的方法
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
    didFinishDownloadingToURL:(NSURL *)location{
    NSString* fullPath =
    [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
            stringByAppendingPathComponent:downloadTask.response.suggestedFilename];;
    [[NSFileManager defaultManager] moveItemAtURL:location
                                            toURL:[NSURL fileURLWithPath:fullPath]
                                            error:nil];
    NSLog(@"%@",fullPath);
}
// 请求完成，错误调用的代理方法
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    NSLog(@"%@",error);
}
#pragma mark - 懒加载
-(NSData *)resumeData{
    if (!_resumeData) {
        _resumeData = [NSData data];
    }
    return _resumeData;
}
#pragma mark - 设置状态栏样式 为亮白色
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
@end
