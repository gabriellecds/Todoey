
#import "UIAppearance+Swift.h"
#import <CloudKit/CloudKit.h>

@implementation UIView (UIViewAppearance_Swift)

+ (instancetype)appearanceWhenContainedWithin:(NSArray *)containers {
    
    NSUInteger count = containers.count;
    NSAssert(count <= 10, @"The count of containers greater than 10 is not supported.");
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_0
    return (id)[self appearanceWhenContainedIn:[containers array]];
#else
    return [self appearanceWhenContainedInInstancesOfClasses:containers];
#endif
}

@end

