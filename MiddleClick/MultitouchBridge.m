#import "MultitouchBridge.h"
#import "MultitouchSupport.h"

static TouchCountCallback _globalCallback = nil;

static void mtContactCallback(MTDeviceRef device,
                               MTTouch *touches,
                               int32_t numTouches,
                               double timestamp,
                               int32_t frame) {
    if (!_globalCallback) return;

    // Su macOS 26+ la struttura MTTouch ha cambiato dimensione interna,
    // rendendo inaffidabile l'accesso a touches[i].state per i >= 1.
    // Il sistema calcola già correttamente numTouches, quindi lo usiamo
    // direttamente come conteggio delle dita attive.
    // Per evitare falsi positivi da dita in "avvicinamento" (stato 1/2),
    // usiamo lo stato della prima dita (che è sempre leggibile correttamente)
    // per determinare se c'è un tocco reale in corso.
    if (numTouches == 0) {
        _globalCallback(0);
        return;
    }
    MTTouchState firstState = touches[0].state;
    bool isActive = (firstState == MTTouchStateMakeTouch ||
                     firstState == MTTouchStateTouching  ||
                     firstState == MTTouchStateBreakTouch);
    _globalCallback(isActive ? numTouches : 0);
}

@implementation MultitouchBridge {
    NSMutableArray *_devices;
}

+ (instancetype)shared {
    static MultitouchBridge *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MultitouchBridge alloc] init];
    });
    return instance;
}

- (void)startWithCallback:(TouchCountCallback)callback {
    _globalCallback = [callback copy];
    _devices = [NSMutableArray array];

    CFMutableArrayRef listRef = MTDeviceCreateList();
    NSArray *deviceList = (__bridge_transfer NSArray *)listRef;

    for (id device in deviceList) {
        MTDeviceRef deviceRef = (__bridge MTDeviceRef)device;
        MTRegisterContactFrameCallback(deviceRef, mtContactCallback);
        MTDeviceStart(deviceRef, 0);
        [_devices addObject:device];
    }
}

- (void)stop {
    for (id device in _devices) {
        MTDeviceRef deviceRef = (__bridge MTDeviceRef)device;
        MTUnregisterContactFrameCallback(deviceRef, mtContactCallback);
        MTDeviceStop(deviceRef);
    }
    [_devices removeAllObjects];
    _globalCallback = nil;
}

@end
