#pragma once

#include <CoreFoundation/CoreFoundation.h>

typedef struct __MTDevice* MTDeviceRef;

typedef enum {
    MTTouchStateNotTracking = 0,
    MTTouchStateStartInRange = 1,
    MTTouchStateHoverInRange = 2,
    MTTouchStateMakeTouch = 3,
    MTTouchStateTouching = 4,
    MTTouchStateBreakTouch = 5,
    MTTouchStateLingerInRange = 6,
    MTTouchStateOutOfRange = 7,
} MTTouchState;

typedef struct {
    int32_t    frame;
    double     timestamp;
    int32_t    identifier;
    MTTouchState state;
    int32_t    unknown1;
    int32_t    unknown2;
    float      normalizedVector_x;
    float      normalizedVector_y;
    float      zTotal;
    int32_t    unknown3;
    int32_t    unknown4;
    float      size;
    int32_t    unknown5;
    float      angle;
    float      majorAxis;
    float      minorAxis;
    float      normalizedVector2_x;
    float      normalizedVector2_y;
    float      unknown6;
    int32_t    unknown7;
    int32_t    unknown8;
} MTTouch;

typedef void (*MTContactCallbackFunction)(MTDeviceRef, MTTouch*, int32_t, double, int32_t);

CFMutableArrayRef MTDeviceCreateList(void);
void MTRegisterContactFrameCallback(MTDeviceRef, MTContactCallbackFunction);
void MTUnregisterContactFrameCallback(MTDeviceRef, MTContactCallbackFunction);
void MTDeviceStart(MTDeviceRef, int32_t);
void MTDeviceStop(MTDeviceRef);
void MTDeviceRelease(MTDeviceRef);
bool MTDeviceIsBuiltIn(MTDeviceRef);
