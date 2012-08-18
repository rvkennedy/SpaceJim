#import <Foundation/NSObject.h>
#import "SJCollisionProtocol.h"

@class Texture2D;
enum
{
	kTexture_Earth = 0,
	kTexture_EarthTop,
	numTextures
};


@interface ScrollingLevel : NSObject <SJCollisionProtocol>
{
	Texture2D* textures[numTextures];
	NSMutableArray *landscapeBlocks;
	CGPoint last_col;
}
-(id)init;
-(void)Render;
-(bool)doesCollideFrom:(CGPoint)p1 to:(CGPoint)p2;
-(bool)doesCollide:(CGPoint)p1;
-(CGPoint)getLastCollisionPos;

@end