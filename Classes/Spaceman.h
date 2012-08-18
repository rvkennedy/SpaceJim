#import "Sprite.h"

@interface Spaceman : Sprite
{
	GLfloat		_rotation,_rotationVelocity;
	bool		on_ground;
	bool		shooting;
	float		shoot_x2;
	float		shoot_x1;
	float		shoot_y;
	Texture2D*	shoot_texture;
}
-(id)init;
-(void)move:(float)dTime;
-(void)setWalk:(float)speed;
-(void)jump;
-(void)shoot;
@end