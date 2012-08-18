#import "SJViewController.h"
#import "MyEAGLView.h"
@implementation SJViewController

// Subclasses override this method to define how the view they control will respond to device rotation 
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if(interfaceOrientation==UIInterfaceOrientationLandscapeRight||interfaceOrientation==UIInterfaceOrientationLandscapeLeft)
		return YES;
	else
		return NO;
}
- (void)viewWillAppear:(BOOL)animated
{
	CGAffineTransform transform=self.view.transform;
	CGPoint center=CGPointMake(320/2.0,480/2.0);
	self.view.center=center;
	transform=CGAffineTransformRotate(transform,(M_PI/2.0));
	self.view.transform=transform;
}
-(void)hideMenu
{
	[mainMenuView setHidden:YES];
}
-(void)showMenu
{
	[mainMenuView setHidden:NO];
}
/*
- (void)loadView
{
	
}*/
@end
