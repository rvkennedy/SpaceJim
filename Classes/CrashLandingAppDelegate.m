#import <mach/mach_time.h>
#import "CrashLandingAppDelegate.h"
#import "MyEAGLView.h"
#import "SJViewController.h"
#import "SoundEngine.h"
#import "ScrollingLevel.h"
#import "Spaceman.h"

// CONSTANTS
#define kUserNameDefaultKey			@"userName"   // NSString
#define kHighScoresDefaultKey		@"highScores" // NSArray of NSStrings

#define kAccelerometerFrequency		100 // Hz
#define kFilteringFactor			0.1 // For filtering out gravitational affects

#define kRenderingFPS				30.0 // Hz

#define kListenerDistance			1.0  // Used for creating a realistic sound field

// MACROS
// Converts degrees to radians for calculating the orientation of the rocket.
#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)

// Used to randomize the starting condtions of the game
#define RANDOM_SEED() srandom((unsigned)(mach_absolute_time() & 0xFFFFFFFF))

// Used to randomize the position of the base the rocket must land on.
#define RANDOM_FLOAT() ((float)random() / (float)INT32_MAX)

// CLASS INTERFACE
@interface CrashLandingAppDelegate ()
- (void) renderScene;
- (void) resetGame;
- (void) saveScore;
@end

// CLASS IMPLEMENTATIONS
@implementation CrashLandingAppDelegate
@synthesize viewController;

+ (void) initialize
{
	if(self == [CrashLandingAppDelegate class])
	{
		RANDOM_SEED();
		//Make sure we have a default set of high-scores in the preferences
		[[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:[NSArray array] forKey:kHighScoresDefaultKey]];
	}
}


- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	glView = [viewController view];
	[window addSubview:glView];
	[window makeKeyAndVisible];
	
	[application setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
	
	NSBundle*				bundle = [NSBundle mainBundle];
	CGRect				rect = [glView bounds];
	//[[UIScreen mainScreen] bounds];	
	
	// Set up variable for starting the game
	_firstTap = YES;
	_left_button_down=NO;
	_right_button_down=NO;
	
	//Create and editable text field. This is used only when the user successfully lands the rocket.
	_textField = [[UITextField alloc] initWithFrame:CGRectMake(60, 214, 200, 30)];
	[_textField setDelegate:self];
	[_textField setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5]];
	[_textField setTextColor:[UIColor whiteColor]];
	[_textField setFont:[UIFont fontWithName:kFontName size:kStatusFontSize]];
	[_textField setPlaceholder:@"Tap to edit"];

	[_leftButton addTarget:self action:@selector(leftButtonDown) forControlEvents:UIControlEventTouchDown];
	[_leftButton addTarget:self action:@selector(leftButtonUp)
		  forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside ];
	
	[_rightButton addTarget:self action:@selector(rightButtonDown) forControlEvents:UIControlEventTouchDown];
	[_rightButton addTarget:self action:@selector(rightButtonUp) 
		   forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside ];
	
	[_jumpButton addTarget:self action:@selector(jumpButtonDown) forControlEvents:UIControlEventTouchDown];
	[_jumpButton addTarget:self action:@selector(jumpButtonUp) 
		  forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside ];
	
	[_shootButton addTarget:self action:@selector(shootButtonDown) forControlEvents:UIControlEventTouchDown];
	[_shootButton addTarget:self action:@selector(shootButtonUp) 
		  forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside ];
	//[glView addSubview:_rightButton];
	
	[_startButton addTarget:self action:@selector(resetGame) 
		  forControlEvents:UIControlEventTouchUpInside];
	
	//Set up OpenGL projection matrix
	glMatrixMode(GL_PROJECTION);
	glOrthof(0, rect.size.width, 0, rect.size.height, -1, 1);
	glMatrixMode(GL_MODELVIEW);
	
	//Initialize OpenGL states
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_TEXTURE_2D);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	//Loadthe  background texture and configure it
	_textures[kTexture_Title] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:@"Title.png"]];
	glBindTexture(GL_TEXTURE_2D, [_textures[kTexture_Title] name]);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	
	_scrollingLevel=[[ScrollingLevel alloc] init];
	_spaceman=[[Spaceman alloc] init];
	
	[_spaceman setCollisionDelegate:_scrollingLevel];
	
	//Load other textures
	_textures[kTexture_Lander] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:@"Spaceman.png"]];
	_textures[kTexture_Base] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:@"Platform.png"]];
	_textures[kTexture_MainThrust] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:@"ThrustMiddle.png"]];
	_textures[kTexture_LeftThrust] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:@"ThrustLeft.png"]];
	_textures[kTexture_RightThrust] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:@"ThrustRight.png"]];
	_textures[kTexture_Explosion] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:@"Explosion.png"]];
	_textures[kTexture_FuelBar] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:@"EmptyFuelBar.png"]];
	_textures[kTexture_FuelLevel] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:@"FuelBar.png"]];
	_textures[kTexture_LightGreen] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:@"LightGreen.png"]];
	_textures[kTexture_LightRed] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:@"LightRed.png"]];
	_textures[kTexture_LabelSpeed] = [[Texture2D alloc] initWithString:@"Speed" dimensions:CGSizeMake(64, 32) alignment:UITextAlignmentLeft fontName:kFontName fontSize:kLabelFontSize];
	_textures[kTexture_LabelAngle] = [[Texture2D alloc] initWithString:@"Angle" dimensions:CGSizeMake(64, 32) alignment:UITextAlignmentLeft fontName:kFontName fontSize:kLabelFontSize];
	_textures[kTexture_LabelPosition] = [[Texture2D alloc] initWithString:@"Position" dimensions:CGSizeMake(64, 32) alignment:UITextAlignmentLeft fontName:kFontName fontSize:kLabelFontSize];
	_textures[kTexture_Enemy1] = [[Texture2D alloc] initWithImage: [UIImage imageNamed:@"Bird.png"]];	
	// Note that each of the Sound Engine functions defined in SoundEngine.h return an OSStatus value.
	// Although the code in this application does not check for errors, you'll want to add error checking code 
	// in your own application, particularly during development.
	//Setup sound engine. Run  it at 44Khz to match the sound files
	SoundEngine_Initialize(44100);
	// Assume the listener is in the center at the start. The sound will pan as the position of the rocket changes.
	SoundEngine_SetListenerPosition(0.0, 0.0, kListenerDistance);
	// Load each of the four sounds used in the game.
	SoundEngine_LoadEffect([[bundle pathForResource:@"Start" ofType:@"caf"] UTF8String], &_sounds[kSound_Start]);
	SoundEngine_LoadEffect([[bundle pathForResource:@"Success" ofType:@"caf"] UTF8String], &_sounds[kSound_Success]);
	SoundEngine_LoadEffect([[bundle pathForResource:@"Failure" ofType:@"caf"] UTF8String], &_sounds[kSound_Failure]);
	SoundEngine_LoadLoopingEffect([[bundle pathForResource:@"Thrust" ofType:@"caf"] UTF8String], NULL, NULL, &_sounds[kSound_Thrust]);
	
	// Compute the land's "bounds"
	_landerBounds = CGRectMake(0, 0, 84, 66);
	_landerBounds = CGRectOffset(_landerBounds, -_landerBounds.size.width / 2, -_landerBounds.size.height / 2);
	
	//Show window
//	[_window makeKeyAndVisible];
	//Configure and start accelerometer
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	
	//Render the Title frame 
	glDisable(GL_BLEND);
	[_textures[kTexture_Title] drawInRect:[glView bounds]];
	glEnable(GL_BLEND);
	
	//Swap the framebuffer
	[glView swapBuffers];
}

// Release resources when they are no longer needed
- (void) dealloc
{
	unsigned			i;
	
	[_statusTexture release];	
	SoundEngine_Teardown();	
	for(i = 0; i < kNumTextures; ++i)
		[_textures[i] release];	
	[_textField release];
	[glView release];
	[window release];
	[_leftButton release];
	[_rightButton release];
	[_scrollingLevel release];
	
	[super dealloc];
}

// Implement this method to get the lastest data from the accelerometer 
- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	//Use a basic low-pass filter to only keep the gravity in the accelerometer values
	_accelerometer[0] = acceleration.x * kFilteringFactor + _accelerometer[0] * (1.0 - kFilteringFactor);
	_accelerometer[1] = acceleration.y * kFilteringFactor + _accelerometer[1] * (1.0 - kFilteringFactor);
	_accelerometer[2] = acceleration.z * kFilteringFactor + _accelerometer[2] * (1.0 - kFilteringFactor);
}

// Saves the user name and score after the user enters it in the provied text field. 
- (void)textFieldDidEndEditing:(UITextField*)textField {
	//Save name
	[[NSUserDefaults standardUserDefaults] setObject:[textField text] forKey:kUserNameDefaultKey];
	
	//Save the score
	[self saveScore];
}

// Terminates the editing session
- (BOOL)textFieldShouldReturn:(UITextField*)textField {
	//Terminate editing
	[textField resignFirstResponder];
	
	return YES;
}

// Saves the user's score in the application preferences
- (void)saveScore
{
	NSUserDefaults*		defaults = [NSUserDefaults standardUserDefaults];
	NSString*			name = [defaults stringForKey:kUserNameDefaultKey];
	NSDate*				date = [NSDate date];
	NSMutableArray*		scores;
	NSMutableString*	string;
	unsigned			i;
	NSDictionary*		dictionary;
	
	//Dismiss text field
	[_textField endEditing:YES];
	[_textField removeFromSuperview];
	
	//Make sure a player name exists, if only the default
	if(![name length])
		name = @"Player";
	
	//Update the high-scores in the preferences
	scores = [NSMutableArray arrayWithArray:[defaults objectForKey:kHighScoresDefaultKey]];
	[scores addObject:[NSDictionary dictionaryWithObjectsAndKeys:name, @"name", [NSNumber numberWithUnsignedInt:_score], @"score", date, @"date", nil]];
	[scores sortUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO] autorelease]]];
	[defaults setObject:scores forKey:kHighScoresDefaultKey];
	
	//Display high-scores in status texture
	string = [NSMutableString stringWithString:@"       HIGH-SCORES\n"];
	for(i = 0; i < MIN([scores count], 10); ++i) {
		dictionary = [scores objectAtIndex:i];
		[string appendFormat:@"\n%s%i. %@ (%@ Pts)", ([[dictionary objectForKey:@"date"] isEqualToDate:date] ? "> " : "   "), i + 1, [dictionary objectForKey:@"name"], [dictionary objectForKey:@"score"]/*, [[dictionary objectForKey:@"date"] descriptionWithCalendarFormat:@"%m/%d %I:%M %p" timeZone:nil locale:nil]*/];
	}
	[_statusTexture release];
	_statusTexture = [[Texture2D alloc] initWithString:string dimensions:CGSizeMake(256, 256) alignment:UITextAlignmentLeft fontName:kFontName fontSize:kScoreFontSize];
	_state = kState_StandBy;
	
	//Render a frame
	[self renderScene];
}


// Called by touchesEnded:withEvent: when the user taps the screen
- (void)handleTap
{
	{ // Either the user tapped to start a new game or the user successfully landed the rocket.
		
		//In the lander was landed successfully, save the current score or start a new game
		if(_state == kState_Success)
		{
			//Stop rendering timer
			[_timer invalidate];
			_timer = nil;
			[self saveScore];
		}
		else if(_state==kState_Failure||_state==kState_StandBy)
		{
			[self resetGame];
		}
	}
}
// Release the status texture and initialized values in preparation for starting a new game
- (void)resetGame
{
	
	if (_firstTap)
	{ // Replace the title screen with the background
		//Load background texture and configure it
		_textures[kTexture_Background] = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"BackgroundStars.png"]];
		glBindTexture(GL_TEXTURE_2D, [_textures[kTexture_Background] name]);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		//Reset
		_firstTap = NO;
	}
	[viewController hideMenu];
	CGRect				bounds = [glView bounds];
	
	//Destroy the status texture
	[_statusTexture release];
	_statusTexture = nil;
	
	//Reset the state to running mode
	_state = kState_Running;
	_lastTime = CFAbsoluteTimeGetCurrent();
	_lastThrust = NO;
	
	//Randomize the landing base position
	_basePosition = RANDOM_FLOAT() * (bounds.size.width - kBaseSize) + kBaseSize / 2;
	
	//Set the initial state or the rocket
	_fuel = kInitialFuel;
	
	_cameraOffset.x=0;
	_cameraOffset.y=0;
	//Render a frame immediately
	[self renderScene];
	
	//Start rendering timer
	_timer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / kRenderingFPS) target:self selector:@selector(renderScene) userInfo:nil repeats:YES];
	
	//Play start sound
	SoundEngine_StartEffect( _sounds[kSound_Start]);
}

- (void)leftButtonDown
{
	_left_button_down=YES;
}

- (void)rightButtonDown
{
	_right_button_down=YES;
}

- (void)leftButtonUp
{
	_left_button_down=NO;
}

- (void)rightButtonUp
{
	_right_button_down=NO;
}

- (void)jumpButtonDown
{
	_jump_button_down=YES;
}

- (void)jumpButtonUp
{
	_jump_button_down=NO;
}

- (void)shootButtonDown
{
	_shoot_button_down=YES;
}

- (void)shootButtonUp
{
	_shoot_button_down=NO;
}

// Renders one scene of the game
- (void)renderScene
{
	CGRect				bounds = [glView bounds];
	float				maxDistance = (kBaseSize - _landerBounds.size.width) / 2.0;
	BOOL				thrust = NO;
	CFTimeInterval		time;
	float				dTime;
//	Vector2D			force;//orientation;
	//CGRect				rect;
	//float				lateralAcceleration;
	CGSize				size;
	
	Vector2D _position;
	Vector2D _velocity;
	//Update game state
	if(_state == kState_Running)
	{
		time = CFAbsoluteTimeGetCurrent();
		dTime = time - _lastTime;
		if(dTime>0.1)
			dTime=0.1;
		[_spaceman move:dTime];
		_position=[_spaceman getPosition];
		_velocity=[_spaceman getVelocity];
		
		//Wrap the lander horizontal position
		float scrollVelocity_x=0;
		if(-_cameraOffset.x+_position.x < 64.0)
		{
			scrollVelocity_x=(-_cameraOffset.x+_position.x-64.0);
			if(scrollVelocity_x<-200.f)
				scrollVelocity_x=-200.f;
		}
		else if(-_cameraOffset.x+_position.x > bounds.size.width/2.0-32.0)
		{
			scrollVelocity_x=(-_cameraOffset.x+_position.x-bounds.size.width/2.0+32.0);
			if(scrollVelocity_x>200.f)
				scrollVelocity_x=200.f;
		}
		_cameraOffset.x+= scrollVelocity_x;
		//Check to see if the rocket touched the ground
	/*	orientation.x = sinf(DEGREES_TO_RADIANS(_rotation));
		orientation.y = cosf(DEGREES_TO_RADIANS(_rotation));
		rect = CGRectApplyAffineTransform(_landerBounds, CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(_rotation)));
		if(_position.y + CGRectGetMinY(rect) <= kBaseOffset + (GLfloat)[_textures[kTexture_Base] pixelsHigh] / 2)
		{
			//Check whether the landing is successful  or not
			if((_velocity.y >= -kMaxVelocity) && (fabsf(_rotation) <= kMaxRotation) && (fabsf(_position.x - _basePosition) < maxDistance))
			{
				SoundEngine_StartEffect(_sounds[kSound_Success]);
				_state = kState_Success;
				_score = kScoreVelocity * (1.0 - _velocity.y / -kMaxVelocity) + kScoreFuel * (_fuel / kInitialFuel) + kScoreRotation * (1.0 - _rotation / kMaxRotation) + kScoreDistance * (1.0 - fabsf(_position.x - _basePosition) / maxDistance);
				_statusTexture = [[Texture2D alloc] initWithString:[NSString stringWithFormat:@"SUCCESS!\nYou scored %i Points\n\nEnter your name:", _score] dimensions:CGSizeMake(256, 128) alignment:UITextAlignmentCenter fontName:kFontName fontSize:kStatusFontSize];

				//Show text field that allows the user to enter a name for the score
				[_textField setText:[[NSUserDefaults standardUserDefaults] stringForKey:kUserNameDefaultKey]];
				[window addSubview:_textField];
			}
			else
			{  // The landing is not successful; the rocket crashed!
				SoundEngine_Vibrate();
				SoundEngine_SetEffectPosition(_sounds[kSound_Failure], 2.0 * (_position.x / bounds.size.width) - 1.0, 0.0, 0.0);
				SoundEngine_StartEffect(_sounds[kSound_Failure]);
				_state = kState_Failure;
				_statusTexture = [[Texture2D alloc] initWithString:@"Hi Arwen!" dimensions:CGSizeMake(256, 32) alignment:UITextAlignmentCenter fontName:kFontName fontSize:kStatusFontSize];
			}

			//Stop rendering timer
			[_timer invalidate];
			_timer = nil;
		}
		//Update lander velocity, rotation speed and fuel
		else*/
		{
			float walk;
			if(_left_button_down&&!_right_button_down)
				walk=-1.f;
			else if(!_left_button_down&&_right_button_down)
				walk=1.f;
			else
				walk=0.f;
			[_spaceman setWalk:walk];
			if(_jump_button_down)
				[_spaceman jump];
			if(_shoot_button_down)
				[_spaceman shoot];
			_lastTime = time;
		}

		//Start or stop thrust sound & update its position
		if(thrust && !_lastThrust)
			SoundEngine_StartEffect( _sounds[kSound_Thrust]);
		else if(!thrust && _lastThrust)
			 SoundEngine_StopEffect(_sounds[kSound_Thrust], false);
		if(thrust)
			SoundEngine_SetEffectPosition(_sounds[kSound_Thrust], 2.0 * (_position.x / bounds.size.width) - 1.0, 0.0, 0.0);
		_lastThrust = thrust;
	}
	//Draw background
	glDisable(GL_BLEND);
	[_textures[kTexture_Background] drawInRect:bounds];
	glEnable(GL_BLEND);
	
	//Draw the game elements
	if(_state != kState_StandBy)
	{
		glPushMatrix();
		glTranslatef(-_cameraOffset.x,-_cameraOffset.y,0.0);
		[_scrollingLevel Render];
		//Draw the landing base
		[_textures[kTexture_Base] drawAtPoint:CGPointMake(_basePosition, kBaseOffset)];
		
		//Draw the lander
		[ _spaceman Render];
		if(_velocity.x<-0.1||_velocity.x>0.1)
		{
			[_spaceman setAnimation:@"Walk"];
			[_spaceman setAnimationRate:3];
		}
		else
		{
			[_spaceman setAnimationRate:0];
		}
		
		//Draw the enemy
		glPushMatrix();
		[_textures[kTexture_Enemy1] drawAtPoint:CGPointMake(40,80)];
		glPopMatrix();
		
		//Draw the explosion if the lander is crashed
		if(_state == kState_Failure)
			[_textures[kTexture_Explosion] drawAtPoint:CGPointMake(_position.x, _position.y)];
		
		glPopMatrix();
		
		//Draw the status lights
		[_textures[(_velocity.y >= -kMaxVelocity ? kTexture_LightGreen : kTexture_LightRed)] drawAtPoint:CGPointMake(kSpeedX, kLightY)];
		//[_textures[(fabsf(_rotation) <= kMaxRotation ? kTexture_LightGreen : kTexture_LightRed)] drawAtPoint:CGPointMake(kAngleX, kLightY)];
		[_textures[(fabsf(_position.x - _basePosition) < maxDistance ? kTexture_LightGreen : kTexture_LightRed)] drawAtPoint:CGPointMake(kPositionX, kLightY)];
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		[_textures[kTexture_LabelSpeed] drawAtPoint:CGPointMake(kSpeedX + kLabelOffset, kLabelY)];
		[_textures[kTexture_LabelAngle] drawAtPoint:CGPointMake(kAngleX + kLabelOffset, kLabelY)];
		[_textures[kTexture_LabelPosition] drawAtPoint:CGPointMake(kPositionX + kLabelOffset, kLabelY)];
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
		//Draw the fuel bar
		if(_state == kState_Running)
		{
			size = [_textures[kTexture_FuelBar] contentSize];
			[_textures[kTexture_FuelBar] drawAtPoint:CGPointMake(kFuelBarX, kFuelBarY)];
			if(_fuel > 0)
				[_textures[kTexture_FuelLevel] drawInRect:CGRectMake(kFuelBarX - size.width / 2 + 1, kFuelBarY - size.height / 2 + 1, size.width - 2, _fuel / kInitialFuel * (size.height - 2))];
		}
	}
	
	//Draw the overlay status texture
	if(_statusTexture)
	{
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		[_statusTexture drawAtPoint:CGPointMake(bounds.size.width / 2, bounds.size.height * 2 / 3)];
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	}
	
	//Swap the framebuffer
	[glView swapBuffers];
}

@end
