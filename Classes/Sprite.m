#include "Sprite.h"
#import "Texture2D.h"

@implementation Anim
-(id)init
{
	self=[super init];
	frames=[[NSMutableArray alloc] init];
	return self;
}

-(void)addFrame:(int)f
{
	[frames addObject:[NSNumber numberWithInt:f]];
}

-(int)getFrame:(int)i
{
	return [[frames objectAtIndex:i] intValue];
}

-(int)numFrames
{
	return [frames count];
}

-(void)dealloc
{
	[frames release];
	[super dealloc];

}
@end

@implementation Sprite

@synthesize collisionDelegate=_collisionDelegate;
- (id) init:(NSString *)proplist
{
	self=[super init];

	_position.x = 96;
	_position.y = 120;
	_velocity.x = 0.0;
	_velocity.y = 0.0;
	frameWait=0;
	currentFrame=0;
	textures=[[NSMutableArray alloc] initWithCapacity:1];
	// read the element data from the plist
	NSString *thePath = [[NSBundle mainBundle]  pathForResource:proplist ofType:@"plist"];
	animSourceDict = [[NSDictionary alloc] initWithContentsOfFile:thePath];
	animDict = [[NSMutableDictionary alloc] init];
	int framenum=0;
	// for each anim
	for (id key in animSourceDict)
	{
		NSString *animName=key;
		NSArray *frames=[animSourceDict objectForKey:key];
		NSString *eachFramename;
		Anim *thisAnim=[[Anim alloc] init];
		currentAnim=thisAnim;
		[animDict setObject:thisAnim forKey:animName];
		for (eachFramename in frames)
		{
			Texture2D *tex=[[Texture2D alloc] initWithImage: [UIImage imageNamed:eachFramename]];
			[textures addObject:tex];
			[thisAnim addFrame:framenum];
			framenum++;
		}
	}
//texture= [[Texture2D alloc] initWithImage: [UIImage imageNamed:@"SpacemanWalk1.png"]];
	return self;
}

-(void) Render
{
	frameWait--;
	if(animationRate&&frameWait<=0)
	{
		currentFrame++;
		frameWait=animationRate;
	}
	if(currentFrame>=[currentAnim numFrames])
		currentFrame=0;
	// which anim? which frame of the anim?
//[texture drawAtPoint:CGPointMake(_position.x+30,_position.y)];
	int frame=[currentAnim getFrame:currentFrame];
	[[textures objectAtIndex:frame] drawAtPoint:CGPointMake(_position.x,_position.y)];
}

-(void)setPosition:(Vector2D)pos
{
	_position=pos;
}

-(void)setVelocity:(Vector2D)vel
{
	_velocity=vel;
}

-(void)setAnimation:(NSString*)name
{
	Anim * an=[animDict objectForKey:name];
	if(an!=currentAnim)
	{
		currentFrame=0;
		frameWait=animationRate;
	}
}

-(void)setAnimationRate:(int)rate
{
	animationRate=rate;
}

- (void) dealloc
{
	for(Texture2D *eachTexture in textures)
	{
		[eachTexture release];
	}
	[textures release];
	[animSourceDict release];
	[animDict release];
//[texture release];
	[super dealloc];
}

-(void)move:(float)dTime
{
}
-(Vector2D)getPosition
{
	return _position;
}
-(Vector2D)getVelocity
{
	return _velocity;
}

@end
