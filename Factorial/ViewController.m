//
//  ViewController.m
//  JM_Autolayout
//
//  Created by FBI on 16/4/8.
//  Copyright © 2016年 君陌. All rights reserved.
//

#import "ViewController.h"

#define MutiRemainNum(x, y) ((x) * (y) % 10)
#define MutiRealNum(x, y)   ((x) * (y) / 10)

#define AddRemainNum(x, y) (((x) + (y)) % 10)
#define AddRealNum(x, y)   (((x) + (y)) / 10)


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self cacluteBigNum:1000];
}

- (void) cacluteBigNum:(NSInteger) number{
    
    //100!可以算成最少90个2位数相乘最多为180位 9!为为6位数,所以最终结果最多有186位,按190位算
    //分解乘法12 * 98
    /*
     个位为2 * 8 = 16 。。。余6进1,6为个位,1为十位
     十位为1 * 8 + 1 + (2 * 9 = 18,余8进1,8为十位,1为百位) = 17 。。。余7进1,7为十位,1为百位,此处相当于进了两百位
     百位为1 * 9 + 2 = 11。。。余1进1,1为百位,1为千位
     千位为0 + 1 = 1;
     最终结果为 1176
     
     所以我们要做的就是把每个数的每个位分割出来 最后通过简单的 乘法和加法（进位）就可以得到最终的结果
     */

    CFTimeInterval beginTime = CACurrentMediaTime();
    NSMutableArray * totalArr = [self seperateNum:1];
    for (NSInteger i = 2; i < number; i ++) {
        
        NSMutableArray * tempNumArr = [self seperateNum:i];
//        NSMutableArray * tempTotalArr = [NSMutableArray arrayWithArray:totalArr];
        totalArr = [self multiFristNum:totalArr secondNum:tempNumArr];

//        NSLog(@"%@ * %@ == %@", [tempTotalArr componentsJoinedByString:@""],[tempNumArr componentsJoinedByString:@""],[totalArr componentsJoinedByString:@""]);
    }
    
    CFTimeInterval endTime = CACurrentMediaTime();
    
    NSMutableArray * finalArr = [NSMutableArray array];
    
    BOOL isValid = NO;
    for (NSNumber * number in [totalArr reverseObjectEnumerator]) {
        if ([number integerValue]) {
            //因为数组中0充当占位符的缘故 可能 数组的末尾存在0 这些0是无效的数字 不用加入最终结果里
            isValid = YES;
        } else {
            continue;
        }
        
        if (isValid) {
            //所有通过 2个数相乘计算的数 都是倒着算的 因为这样容易做进位的处理 所以最后的结果要返回来
            [finalArr addObject:number];
        }
    }
    
    NSLog(@"%ld! ====== %@ beginTime == %f endTime == %f timeOff == %f", (long)number, [finalArr componentsJoinedByString:@""], beginTime, endTime, endTime - beginTime);
}

#pragma mark - 分割大的数字
/**
 *
 *  @param num 数字
 *
 *  @return 按位分割后的数组
 */
- (NSMutableArray *) seperateNum:(NSUInteger) num{
    
    NSMutableArray * tempArr = [NSMutableArray arrayWithCapacity:20];
    
    do {
        if (num < 10 && num > 0) {
            [tempArr addObject:@(num)];
        } else {
            [tempArr addObject:@(num % 10)];
        }
        num /= 10;
    } while (num);
    
    return tempArr;
}

#pragma mark - 计算两个数的乘积
/**
 *
 *  @param fNum 其中之一数字
 *  @param sNum 其中之二数字
 *
 *  @return 两个数的乘积,数组从右到左
 */
- (NSMutableArray *) multiFristNum:(NSMutableArray *) fNumArr secondNum:(NSMutableArray *) sNumArr{
    
    //两位数相乘得到的最大数的数组,空间大小为两位数位数相加
    NSMutableArray * tempArr = [NSMutableArray array];
    for (NSInteger i = 0; i < fNumArr.count + sNumArr.count; i ++) {
        [tempArr addObject:@(0)];
    }
    
    for (NSInteger i = 0; i < fNumArr.count; i ++) {
        //乘数第I位的数字
        
        NSInteger frNum = [fNumArr[i] integerValue];
        for (NSInteger j = 0; j < sNumArr.count; j ++) {
            //被乘数第J位的数字
            NSInteger seNum = [sNumArr[j] integerValue];
            //两数相乘的乘积
            NSInteger product = seNum * frNum;
            //位数为i + j位的数值
            NSInteger numCurrent = [tempArr[i + j] integerValue];
//            numCurrent = (numCurrent == - 1 ? 0 : numCurrent);
            //两数相加的余数
            NSInteger remainNum = AddRemainNum(numCurrent, product);
            //若大于10得到的进位数
            NSInteger realNum = AddRealNum(numCurrent, product);
            
            //当前位数则为remainNum
            tempArr[i + j] = @(remainNum);
            if (realNum) {
                
                NSInteger nextRealNum = realNum;
                for (NSInteger k = i + j + 1; k < fNumArr.count + sNumArr.count; k ++) {//如果有进位则从 第K位开始往前计算 相同位之和

                    //位数为k位的数
                    NSInteger numCurrent = [tempArr[k] integerValue];
//                    numCurrent = (numCurrent == - 1 ? 0 : numCurrent);
                    //若大于10得到的进位数
                    NSInteger realTempNum = AddRealNum(nextRealNum, numCurrent);
                    //两数相加的余数
                    NSInteger remainNum = AddRemainNum(nextRealNum, numCurrent);
                    
                    tempArr[k] = @(remainNum);
                    if (realTempNum) {
                        nextRealNum = realTempNum;
                    } else {
                        break;
                    }
                }
            }
        }
    }
    
    return tempArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
