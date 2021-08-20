//
//  MoveSquareViewController.m
//  OpenGL ES
//
//  Created by x on 2021/8/19.
//

#import "MoveSquareViewController.h"
#import "os_square.h"       // 存放定点坐标 和 颜色值
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface MoveSquareViewController ()

@property (nonatomic, strong) EAGLContext *context;

@end

@implementation MoveSquareViewController

/*  OPenGL ES _ 入门练习_003
 *  https://www.jianshu.com/p/36d9dac03345
 *  学习目标 使用OpenGL ES 绘制一个移动的正方形
 *  步骤1: 创建一个 GLKViewController
 *  步骤2: 创建一个EAGContext 跟踪我们所有的特定的状态，命令和资源
 *  步骤3: 清除屏幕
 *  步骤4: 创建投影坐标系
 *  步骤5: 创建物体自身坐标系
 *  步骤6: 加载定点数据
 *  步骤7: 加载颜色数据
 *  步骤8: 开始绘制
 */


- (void)config {
    GLKView *temp = (GLKView *)self.view;
    temp.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    temp.context = self.context;
}

- (void)clear {
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
}

- (void)initProjectionMatrix {
    glMatrixMode(GL_PROJECTION);    // 设置投影模式
    glLoadIdentity();               // 导入
}

// 创建自身坐标
- (void)initModelView {
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    static float transY = 0;
    glTranslatef(0, (GLfloat)(sinf(transY)/2), 0);
//    glTranslatef(0.0, (GLfloat)(sinf(transY)/2.0), 0.0);
    transY += 0.01f;
}

// 加载顶点数据
- (void)loadVertexData {
    glVertexPointer(2, GL_FLOAT, 0, squareVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
}
// 加载颜色数据
- (void)loadColorData {
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
    glEnableClientState(GL_COLOR_ARRAY);
}

// 开始绘制
- (void)draw {
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

// 重写回调函数
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self clear];
    [self initProjectionMatrix];
    [self initModelView];
    [self loadVertexData];
    [self loadColorData];
    [self draw];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self config];
}

- (EAGLContext *)context {
    if (_context == nil) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        [EAGLContext setCurrentContext:_context];
    }
    return _context;
}

@end
