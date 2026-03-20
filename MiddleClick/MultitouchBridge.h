#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TouchCountCallback)(int touchCount);

@interface MultitouchBridge : NSObject

+ (instancetype)shared;

- (void)startWithCallback:(TouchCountCallback)callback;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
