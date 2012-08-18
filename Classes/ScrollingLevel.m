#import "ScrollingLevel.h"
#import "Texture2D.h"

@interface LandscapeVertex : NSObject
{
	float x,y;
}
@end

@implementation LandscapeVertex
-(id)initWithX:(float)xx andY:(float)yy
{
	self=[super init];
	x=xx;
	y=yy;
	return self;
}
@end
	
@interface LandscapeBlock : NSObject
{
	float x1,x2,y1,y2,h1,h2;
	Texture2D *texture;	
	Texture2D *topTexture;	
	CGPoint last_col;
}
-(bool)doesCollideFrom:(CGPoint)p1 to:(CGPoint)p2;
@end
float Dot(CGPoint X1,CGPoint X2)
{
	return X1.x*X2.x+X1.y*X2.y;
}
float Intersection(CGPoint X1,CGPoint x1,CGPoint X2,CGPoint x2)
{
	CGPoint DX;
	DX.x=X1.x-X2.x;
	DX.y=X1.y-X2.y;
	CGPoint D1;
	D1.x=x1.x-X1.x;
	D1.y=x1.y-X1.y;
	CGPoint D2;
	D2.x=x2.x-X2.x;
	D2.y=x2.y-X2.y;
	float d1d2=Dot(D1,D2);
	float d11=Dot(D1,D1);
	float d22=Dot(D2,D2);
	float d1d2_1=(d11*d22-(d1d2*d1d2));
	if(d1d2_1>0.0001)
	{
		float alpha2=1.0/d1d2_1*(-d1d2*(Dot(D1,DX)+d11*Dot(D2,DX)));
		if(alpha2<0||alpha2>1.0)
			return 10000.0;
		return 1.0/d1d2_1*(-d22*(Dot(D1,DX)+d1d2*Dot(D2,DX)));
	}
	else
	{
		return 10000.0;
	}
}

@implementation LandscapeBlock

-(id)initWithTexture:(Texture2D*)tex andTop:(Texture2D *)topTex
{
	self=[super init];
	texture=tex;
	topTexture=topTex;
	x1=0;
	x2=480;
	y1=0;
	y2=0;
	h1=96;
	h2=128;
	return self;
}
-(void)setX1:(float)X1 andX2:(float)X2
{
	x1=X1;
	x2=X2;
}
-(void)setY1:(float)Y1 andY2:(float)Y2
{
	y1=Y1;
	y2=Y2;
}
-(void)setH1:(float)H1 andH2:(float)H2
{
	h1=H1;
	h2=H2;
}
-(bool)doesCollide:(CGPoint)q
{
	if(q.x<x1||q.x>x2)
		return NO;
	float along=(q.x-x1)/(x2-x1);
	float y=y1+along*(y2-y1);
	float h=h1+along*(h2-h1);
	if(q.y<y)
		return NO;
	if(q.y>y+h)
		return NO;
	last_col.x=q.x;
	last_col.y=y+h;
	return YES;
}
-(bool)doesCollideFrom:(CGPoint)q1 to:(CGPoint)q2
{
	if(![self doesCollide:q2])
		return NO;
	if([self doesCollide:q1])
		return NO;

	/*CGPoint p1=CGPointMake(x1,y1);
	CGPoint p2=CGPointMake(x2,y2);
	CGPoint p3=CGPointMake(x1,y1+h1);
	CGPoint p4=CGPointMake(x2,y2+h2);
	
	float dist1=Intersection(q1,q2,p1,p2);
	float dist2=Intersection(q1,q2,p2,p3);
	float dist3=Intersection(q1,q2,p3,p4);
	float dist4=Intersection(q1,q2,p4,p1);
	
	float dist=dist1;
	if(dist2<dist1)
		dist=dist2;
	if(dist3<dist)
		dist=dist3;
	if(dist4<dist)
		dist=dist4;*/
	//last_col.x=q1.x+(q2.x-q1.x)*dist;
	//last_col.y=q1.y+(q2.y-q1.y)*dist;
	return YES;
}
-(CGPoint)getLastCollisionPos
{
	return last_col;
}


-(void)Render
{
	CGPoint p1=CGPointMake(x1,y1);
	CGPoint p2=CGPointMake(x2,y2);
	CGPoint p3=CGPointMake(x1,y1+h1);
	CGPoint p4=CGPointMake(x2,y2+h2);
	Quad quad=QuadMake(p1,p2,p3,p4);
	[texture repeatInQuad:quad withWidth:32 andHeight:32];
	p1=CGPointMake(x1,y1+h1-32);
	p2=CGPointMake(x1,y1+h1);
	p3=CGPointMake(x2,y2+h2-32);
	p4=CGPointMake(x2,y2+h2);
	quad=QuadMake(p1,p2,p3,p4);
	[topTexture drawWithXTiling:quad withWidth:32];
}

-(void)dealloc
{
	[super dealloc];
}


@end

@implementation ScrollingLevel

- (id) init
{
	self=[super init];
	textures[kTexture_Earth] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:@"Earth.png"]];
	textures[kTexture_EarthTop] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:@"EarthTop.png"]];
	landscapeBlocks = [[NSMutableArray alloc] initWithCapacity:5];
	
	
	LandscapeBlock *block3=[[LandscapeBlock alloc] initWithTexture:(textures[kTexture_Earth]) andTop:textures[kTexture_EarthTop]];
	[block3 setX1:320	andX2:640];
	[block3 setY1:0 andY2:0];
	[block3 setH1:320 andH2:128];
	[landscapeBlocks addObject:block3];
	
	LandscapeBlock *block1=[[LandscapeBlock alloc] initWithTexture:(textures[kTexture_Earth]) andTop:textures[kTexture_EarthTop]];
	[block1 setX1:0	andX2:320];
	[block1 setY1:0 andY2:0];
	[block1 setH1:64 andH2:128];
	[landscapeBlocks addObject:block1];
	
	
	LandscapeBlock *block2=[[LandscapeBlock alloc] initWithTexture:(textures[kTexture_Earth]) andTop:textures[kTexture_EarthTop]];
	[block2 setX1:320	andX2:640];
	[block2 setY1:0 andY2:0];
	[block2 setH1:128 andH2:144];
	[landscapeBlocks addObject:block2];
	
	last_col.x=0;
	last_col.y=0;
	return self;
}

-(void) Render
{
	glPushMatrix();
	for (LandscapeBlock *eachLandscapeBlock in landscapeBlocks)
	{
		[eachLandscapeBlock Render];
	}
	glPopMatrix();
}
	
-(bool)doesCollideFrom:(CGPoint)p1 to:(CGPoint)p2
{
	bool result=NO;
	for (LandscapeBlock *eachLandscapeBlock in landscapeBlocks)
	{
		if([eachLandscapeBlock doesCollideFrom:p1 to:p2])
		{
			last_col=[eachLandscapeBlock getLastCollisionPos];
			result=YES;
		}
	}
	return result;
	/*int y1=(int)p1.y;
	int y2=(int)p2.y;
	if(y1>=96&&y2<96)
	{
		last_col.x=p1.x;
		last_col.y=96;
		return YES;
	}
	return NO;*/
}
	
-(bool)doesCollide:(CGPoint)p1
{
	int y1=(int)p1.y;
	if(y1<96)
	{
		last_col.x=p1.x;
		last_col.y=96;
		return YES;
	}
	return NO;
}

-(CGPoint)getLastCollisionPos
{
	return last_col;
}

- (void) dealloc
{
	unsigned i;	
	for(i = 0; i < numTextures; ++i)
		[textures[i] release];
	[landscapeBlocks release];
	[super dealloc];
}

@end
