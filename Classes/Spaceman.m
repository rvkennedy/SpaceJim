
#import "Spaceman.h"

@implementation Spaceman

- (id) init
{
	self=[super init:@"Spaceman"];
	_rotation = 0.0;
	_rotationVelocity = 0.0;
	_position.x = 96;
	_position.y = 120;
	_velocity.x = 0.0;
	_velocity.y = 0.0;
	on_ground=NO;
	shoot_texture = [[Texture2D alloc] initWithImage: [UIImage imageNamed:@"RedLaser.png"]];
	shooting=NO;
	return self;
}

- (void) dealloc
{
	[shoot_texture release];
	[super dealloc];
}

#define kLateralSpeed				90    //Pixels/s

-(void)move:(float)dTime
{
	//Update lander position
	_position.x += _velocity.x * dTime;
	_position.y += _velocity.y * dTime;
		
	//Update the rocket orientation
	_rotation += _rotationVelocity * dTime;
	Vector2D force;
	force.x = 0.0;
	force.y = -kGravity;
	
	_velocity.y += force.y * dTime;
		
	CGPoint p1=CGPointMake(_position.x,_position.y);
	CGPoint p2=CGPointMake(_position.x+_velocity.x*dTime,_position.y+_velocity.y*dTime-24);
	
	if([_collisionDelegate doesCollideFrom:p1 to:p2])
	{
		CGPoint coll_pos=[_collisionDelegate getLastCollisionPos];
		if(_velocity.y<0||on_ground)
			_position.y=coll_pos.y+24;
		if(_velocity.y<0)
		{
			on_ground=YES;
		}
		_velocity.y=0;
	}
	else
	{
		on_ground=NO;
	}
	if(shooting)
	{
		shoot_x2+=dTime*30*80;
		if(shoot_x2>_position.x+480)
		{
			shoot_x1+=dTime*30*80;
		}
		if(shoot_x1>_position.x+480)
		{
			shooting=NO;
		}
	}
}
-(void)Render
{
	[super Render];
	[shoot_texture drawInRect:CGRectMake(shoot_x1, shoot_y-4, shoot_x2-shoot_x1,8)];
}
-(void)setWalk:(float)speed
{
	_velocity.x = speed*kLateralSpeed;
}

-(void)shoot
{
	if(shooting)
		return;
	shooting=YES;
	shoot_x2=shoot_x1=_position.x+16;
	shoot_y=_position.y+8;
}

-(void)jump
{
	if(!on_ground)
		return;
	on_ground=false;
	_velocity.y=200;
	on_ground=NO;
}

@end
