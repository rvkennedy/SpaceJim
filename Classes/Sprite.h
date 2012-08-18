#import <Foundation/NSObject.h>
#import "Texture2D.h"
#import "SJCollisionProtocol.h"

#define kGravity					400    //Pixels/s2
@interface Anim : NSObject
{
	NSMutableArray *frames;
}
-(id)init;
-(void)addFrame:(int)f;
-(int)getFrame:(int)i;
-(int)numFrames;
@end

@interface Sprite : NSObject
{
	int numTextures;
	Vector2D _position;
	Vector2D _velocity;
	id<SJCollisionProtocol>	_collisionDelegate;

	Texture2D *texture;
	NSMutableArray *textures;
	NSDictionary *animSourceDict;
	NSMutableDictionary *animDict;
	Anim *currentAnim;
	int currentFrame;
	int frameWait;
	int animationRate;
}
-(id)init:(NSString *)texturename;
-(void)Render;
-(void)setPosition:(Vector2D)pos;
-(void)setVelocity:(Vector2D)vel;
-(void)setAnimation:(NSString*)name;
-(void)setAnimationRate:(int)rate;
-(void)move:(float)dTime;
-(Vector2D)getPosition;
-(Vector2D)getVelocity;
@property(assign) id<SJCollisionProtocol> collisionDelegate;
@end