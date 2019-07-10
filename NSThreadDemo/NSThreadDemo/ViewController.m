//
//  ViewController.m
//  NSThreadDemo
//
//  Created by lee on 2019/7/7.
//  Copyright © 2019 Onlyou. All rights reserved.
//

#import "ViewController.h"
#import <Foundation/Foundation.h>

@interface ViewController()

@property (nonatomic, strong) NSThread *thread;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, assign) NSUInteger tickets;  //火车票总数

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self saleTicketStart];
    
}

#pragma mark - 创建与启动线程
- (void)createThreadAndStart
{
    //1
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(run:) object:@"1"];
    [thread start];
    
    //2
    NSThread *blockThread = [[NSThread alloc] initWithBlock:^{
        NSLog(@"%@:%@", @"2", [NSThread currentThread]);
    }];
    [blockThread start];
    
    //3
    [NSThread detachNewThreadSelector:@selector(run:) toTarget:self withObject:@"3"];
    
    //4
    [NSThread detachNewThreadWithBlock:^{
        NSLog(@"%@:%@", @"4", [NSThread currentThread]);
    }];
    
    //5
    [self performSelectorInBackground:@selector(run:) withObject:@"5"];
}

//线程执行的任务
- (void)run:(NSString *)argument
{
    NSLog(@"%@:%@", argument, [NSThread currentThread]);
}

#pragma mark - cancel
- (void)testThreadCancel
{
    self.thread = [[NSThread alloc] initWithBlock:^{
        
        NSThread *currentThread = [NSThread currentThread];
        for (int i = 0; i < 6; ++i) {
            NSLog(@"%@, cancel value=%d", currentThread, [currentThread isCancelled]);
            [NSThread sleepForTimeInterval:0.5];
        }
        
    }];
    [self.thread setName:@"cancel"];
    [self.thread start];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.thread cancel];
    });
}

#pragma mark - 下载图片

/**
 创建一个子线程去下载图片
 */
- (void)createSubThreadToDownloadImage
{
    [NSThread detachNewThreadSelector:@selector(downloadImageOnSubThread) toTarget:self withObject:nil];
}
/**
 下载图片 - 子线程
 */
- (void)downloadImageOnSubThread
{
    NSURL *url = [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1562659377213&di=f9dee9bd236f21f9de550e061664ea58&imgtype=0&src=http%3A%2F%2Fres.eqxiu.com%2Fgroup1%2FM00%2FC4%2F19%2Fyq0KA1SGiReALB7PAABDN1llhBs292.png"];
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    
    //图片下载完成后，在主线程显示图片
    [self performSelectorOnMainThread:@selector(showImageOnMainThread:) withObject:image waitUntilDone:NO];
}

//展示图片 - 主线程
- (void)showImageOnMainThread:(UIImage *)image
{
    self.imageView.image = image;
}

#pragma mark - 卖火车票
//两个窗口 相当于 两条线程
- (void)saleTicketStart
{
    self.tickets = 20;  //火车票的总量为20
    
    NSThread *threadA = [[NSThread alloc] initWithTarget:self selector:@selector(saleTicketAction) object:nil];
    NSThread *threadB = [[NSThread alloc] initWithTarget:self selector:@selector(saleTicketAction) object:nil];
    [threadA setName:@"窗口A"];
    [threadB setName:@"窗口B"];
    
    [threadA start];
    [threadB start];
}

//卖火车票 - 非线程安全
- (void)saleTicketAction
{
    while ( 1 ) {
        @synchronized (self) {
            if ( self.tickets > 0 ) {
                --self.tickets;
                NSLog(@"%@卖了一张票，还剩下%lu张票。", [[NSThread currentThread] name], self.tickets);
            } else {
                NSLog(@"不好意思，票已经卖完了。");
                break;
            }
            [NSThread sleepForTimeInterval:1.0];
        }
    }
}

@end
