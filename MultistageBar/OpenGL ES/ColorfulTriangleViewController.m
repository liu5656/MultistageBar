//
//  ViewController.m
//  OpenGL ES
//
//  Created by x on 2021/7/28.
//

#import "ColorfulTriangleViewController.h"

@interface ColorfulTriangleViewController ()
{
    GLuint program;
    GLint vertexColor;
    GLuint vertexBuffer;
}

@property (nonatomic, strong) EAGLContext *context;

@end

@implementation ColorfulTriangleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLKView *temp = (GLKView *)self.view;
    temp.context = self.context;
    temp.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [EAGLContext setCurrentContext:temp.context];
    
    
    program = [self createProgram];
    
    glBindAttribLocation(program, 0, "position");
    
    [self linkProgram:program];
    
    vertexColor = glGetUniformLocation(program, "color");
    
    [self loadVertex];
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    static int count = 0;
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    count++;
    if (count > 50) {
        count = 0;
        glUniform4f(vertexColor, arc4random_uniform(255)/225.0, arc4random_uniform(255)/225.0, arc4random_uniform(255)/225.0, 1);
    }
    glUseProgram(program);
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

static GLfloat vertex[6] = {-1,-1,-1,1,1,1};
- (void)loadVertex {
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertex), vertex, GL_STATIC_DRAW);              // 申请内存空间
    glEnableVertexAttribArray(GLKVertexAttribPosition);                                 // 开启顶点数据
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 8, 0);        // 设置指针
}


- (GLuint)createProgram {
    GLuint vshader, fshader;
    NSString *vpath = [NSBundle.mainBundle pathForResource:@"Shader" ofType:@"vsh"];
    NSString *fpath = [NSBundle.mainBundle pathForResource:@"Shader" ofType:@"fsh"];
    [self compile:&vshader type:GL_VERTEX_SHADER path:vpath];
    [self compile:&fshader type:GL_FRAGMENT_SHADER path:fpath];
    GLuint pro = glCreateProgram();
    glAttachShader(pro, vshader);
    glAttachShader(pro, fshader);
    return pro;
}
- (BOOL)compile:(GLuint *)shader type:(GLenum)type path:(NSString *)path {
    const GLchar *source = (GLchar *)[[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (source == nil) {
        NSLog(@"Failed to load shader");
        return NO;
    }
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#ifdef DEBUG
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"shader compile log: %s", log);
        free(log);
    }
#endif
    
    GLint status;
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (0 == status) {
        glDeleteShader(*shader);
        return NO;
    }
    return YES;
}
- (BOOL)linkProgram:(GLuint)program {
    glLinkProgram(program);
//#ifdef DEBUG
//    GLint logLength;
//    glGetShaderiv(program, GL_INFO_LOG_LENGTH, &logLength);
//    if (0 < logLength) {
//        GLchar *log = (GLchar *)malloc(logLength);
//        glGetProgramInfoLog(program, logLength, &logLength, log);
//        NSLog(@"link program log: %s", log);
//        free(log);
//    }
//#endif
    GLint status;
    glGetShaderiv(program, GL_LINK_STATUS, &status);
    if (0 == status) {
        return NO;
    }
    return YES;;
}

#pragma mark --get
- (EAGLContext *)context {
    if (_context == nil) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    return _context;
}


@end
