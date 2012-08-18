#import <UIKit/UIKit.h>
#import "Texture2D.h"
@class MyEAGLView;
@class SJViewController;
@class ScrollingLevel;
@class Spaceman;

// CONSTANTS
#define kBaseOffset					20
#define kBaseSize					100
#define kFontName					@"Arial"
#define kStatusFontSize				24
#define kLabelFontSize				14
#define kScoreFontSize				18
#define kFuelBarX					300
#define kFuelBarY					350
#define kLabelY						455
#define kLightY						460
#define kSpeedX						20
#define kAngleX						120
#define kPositionX					220
#define kLabelOffset				40

#define kInitialVelocity			100   //Pixels/s
#define kInitialFuel				4    //Seconds
#define kMass						80    //Kg
#define kMainThrustThreshold		-0.10 //Accelerometer Y axis value (about 45 degrees angle)
#define kLateralThrustThreshold		0.00   //Accelerometer X axis value
#define kMainThrust					20000 //N
#define kRotationSpeed				100   //Degrees/s

#define kMaxVelocity				75   //Pixels/s
#define kMaxRotation				8   //Degrees

#define kScoreVelocity				4000
#define kScoreFuel					2500
#define kScoreRotation				2000
#define kScoreDistance				1500

enum {
	kTexture_Title = 0,
	kTexture_Background,
	kTexture_Lander,
	kTexture_Base,
	kTexture_MainThrust,
	kTexture_LeftThrust,
	kTexture_RightThrust,
	kTexture_Explosion,
	kTexture_FuelBar,
	kTexture_FuelLevel,
	kTexture_LightGreen,
	kTexture_LightRed,
	kTexture_LabelSpeed,
	kTexture_LabelAngle,
	kTexture_LabelPosition,
	kTexture_Enemy1,
	kNumTextures
};

enum {
	kSound_Thrust = 0,
	kSound_Start,
	kSound_Success,
	kSound_Failure,
	kNumSounds
};

typedef enum {
	kState_StandBy = 0,
	kState_Running,
	kState_Success,
	kState_Failure
} State;


//CLASS INTERFACE
@interface CrashLandingAppDelegate : NSObject <UIApplicationDelegate, UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate>
{
	IBOutlet UIWindow			*window;
	 MyEAGLView					*glView;
	IBOutlet SJViewController	*viewController;
	
	UITextField*			_textField;
	IBOutlet UIButton*		_leftButton;
	IBOutlet UIButton*		_rightButton;
	IBOutlet UIButton*		_jumpButton;
	IBOutlet UIButton*		_shootButton;
	
	IBOutlet UIButton*		_startButton;
	IBOutlet UIButton*		_optionsButton;

	ScrollingLevel*			_scrollingLevel;
	Texture2D*				_textures[kNumTextures];
	UInt32					_sounds[kNumSounds];
	Spaceman*				_spaceman;
	
	CGRect					_landerBounds;
	UIAccelerationValue		_accelerometer[3];
	Texture2D*				_statusTexture;
	BOOL					_firstTap;
	
	NSTimer*				_timer;
	State					_state;
	CFTimeInterval			_lastTime;
	BOOL					_lastThrust;
	GLfloat					_basePosition;
	Vector2D				_cameraOffset;
	float					_fuel;
	unsigned				_score;

	BOOL					_left_button_down;
	BOOL					_right_button_down;
	bool					_jump_button_down;
	bool					_shoot_button_down;
}
- (void)handleTap;
@property (nonatomic, retain) SJViewController *viewController;
@end
