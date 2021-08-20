//
//  RotateCubeViewController.m
//  OpenGL ES
//
//  Created by x on 2021/8/19.
//

#import "RotateCubeViewController.h"
#import "os_square.h"
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>


@interface RotateCubeViewController ()

@property (nonatomic, strong) EAGLContext *context;

@end

/**
 *  学习目标:绘制一个旋转移动的立方体
 *  https://www.jianshu.com/p/6155d60dab20
 *  第一步: 创建GLKViewController 控制器(在里面实现方法)
 *  第二步: 创建EAGContext 跟踪所有状态,命令和资源
 *  第三步: 清除命令
 *  第四步: 创建投影坐标系
 *  第五步: 创建对象坐标
 *  第六步: 导入顶点数据
 *  第七步: 导入颜色数据
 *  第八步: 绘制
 *  欢迎加群: 578734141 交流学习~
 *
 */

@implementation RotateCubeViewController

- (void)config {
    GLKView *temp = (GLKView *)self.view;
    temp.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    temp.context = self.context;
}

// 清楚命令
- (void)clear {
    glEnable(GL_DEPTH_TEST);
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}
// 创建投影坐标系
- (void)initProjectionMatrix {
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
}
// 创建对象坐标系
- (void)initModelMatrix {
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    static GLfloat transY = 0;
    static GLfloat rotateX = 0;
    static GLfloat rotateY = 0;
    glTranslatef(0, (GLfloat)(sinf(transY) / 2), -2);
    glRotatef(rotateY, 0, 1, 0);
    glRotatef(rotateX, 1, 0, 0);
    transY += 0.075;
    rotateY += 0.25;
    rotateX += 0.25;
}

// 加载顶点数据
- (void)loadVertexData {
    glVertexPointer(3, GL_FLOAT, 0, cubeVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
}
// 加载颜色数据
- (void)loadColorData {
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, cubeColors);
    glEnableClientState(GL_COLOR_ARRAY);
}

// 开始绘制
- (void)draw {
    glEnable(GL_CULL_FACE);     // 开启剔除面功能
    glCullFace(GL_BACK);        // 剔除背面
    glDrawElements(GL_TRIANGLE_FAN, 18, GL_UNSIGNED_BYTE, tfan1);
    glDrawElements(GL_TRIANGLE_FAN, 18, GL_UNSIGNED_BYTE, tfan2);
}

 // 设置窗口及投影坐标的位置
- (void)setClipping {
    const float zNear = 0.1;
    const float zFar = 1000;
    const float fieldOfView = 60.0;
    CGRect frame = UIScreen.mainScreen.bounds;
    float aspectRatio = (float)(frame.size.width / frame.size.height);
    GLfloat size = zNear * tanf(GLKMathDegreesToRadians(fieldOfView) / 2.0);

    [self initProjectionMatrix];

    glFrustumf(-size, size, -size / aspectRatio, size / aspectRatio, zNear, zFar);
    glViewport(0, 0, frame.size.width, frame.size.height);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self clear];
    [self initModelMatrix];
    [self loadVertexData];
    [self loadColorData];
    [self draw];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self config];
    [self setClipping];
}

- (EAGLContext *)context {
    if (_context == nil) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        [EAGLContext setCurrentContext:_context];
    }
    return _context;
}

@end
