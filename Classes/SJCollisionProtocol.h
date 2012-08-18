#import <Foundation/NSObject.h>
@protocol SJCollisionProtocol<NSObject>

-(bool)doesCollideFrom:(CGPoint)p1 to:(CGPoint)p2;
-(bool)doesCollide:(CGPoint)p1;
-(CGPoint)getLastCollisionPos;

@end
