#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

//CLASSES:

@class MyEAGLView;

//PROTOCOLS:

@protocol MyEAGLViewDelegate <NSObject>
- (void) didResizeEAGLSurfaceForView:(MyEAGLView*)view; //Called whenever the EAGL surface has been resized
@end

//CLASS INTERFACE:

/*
 This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
 The view content is basically an EAGL surface you render your OpenGL scene into.
 Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
 */
@interface MyEAGLView : UIView
{
@private
	NSString*				_format;
	GLuint					_depthFormat;
	BOOL					_autoresize;
	EAGLContext				*_context;
	GLuint					_framebuffer;
	GLuint					_renderbuffer;
	GLuint					_depthBuffer;
	CGSize					_size;
	BOOL					_hasBeenCurrent;
	BOOL					_multipleTouchEnabled;
	id<MyEAGLViewDelegate>	_delegate;
}
- (id)initWithCoder:(NSCoder*)coder; 

@property(readonly) GLuint framebuffer;
@property(readonly) NSString* pixelFormat;
@property(readonly) GLuint depthFormat;
@property(readonly) EAGLContext *context;
@property BOOL multipleTouchEnabled;

@property BOOL autoresizesSurface;
//NO by default - Set to YES to have the EAGL surface automatically resized when the view bounds change,
//otherwise the EAGL surface contents is rendered scaled

@property(readonly, nonatomic) CGSize surfaceSize;

@property(assign) id<MyEAGLViewDelegate> delegate;

- (void) setCurrentContext;
- (BOOL) isCurrentContext;
- (void) clearCurrentContext;

- (void) swapBuffers; //This also checks the current OpenGL error and logs an error if needed

- (CGPoint) convertPointFromViewToSurface:(CGPoint)point;
- (CGRect) convertRectFromViewToSurface:(CGRect)rect;
@end
