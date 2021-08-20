//
//  MoveCubeViewController.m
//  OpenGL ES
//
//  Created by x on 2021/8/19.
//

#import "MoveCubeViewController.h"
#import "os_square.h"


/*
 * 学习目标 简单的绘制一个立方体
 * https://www.jianshu.com/p/1ca30e9387dd
 * 亮点 :使用系统封装好的对象来做 代码简洁，好维护
 * 实现步骤:
 * 第一步 .创建一个继承 GLKViewController(为我们封装了好多代码)的对象
 * 第二步 .创建一个EAGLContext 对象负责管理gpu的内存和指令
 * 第三步 .创建一个GLKBaseEffect 对象，负责管理渲染工作
 * 第四步 .创建立方体的顶点坐标和法线
 * 第五步 .绘图
 * 第六步 .让立方体运动其它
 * 第七步 .在视图消失的时候，做一些清理工作
 */

@interface MoveCubeViewController ()

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKBaseEffect *effect;

@end

@implementation MoveCubeViewController
{
    GLuint _vertexBuffer;
    float _rotation;
}

- (void)addVertexAndNormal {
    glEnable(GL_DEPTH_TEST);
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);    // 申请内存空间
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 24, (char *)0);
    
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 24, (char *)12);
}

- (void)clear {
    glClearColor(0.65, 0.65, 0.65, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

// 改变运动轨迹
- (void)changeTrack {
    float aspect = (float)(self.view.bounds.size.width / self.view.bounds.size.height);
    // 透视转换
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65), aspect, 0.1, 100);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -10);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0, 1, 0);
    
    // 计算自身坐标和旋转姿态
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -1.5);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1, 1, 1);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
    
    _rotation += self.timeSinceLastUpdate * 0.5f;
}

// 清除工作
- (void)teardownGL {
    [EAGLContext setCurrentContext:self.context];
    glDeleteBuffers(1, &_vertexBuffer);
    self.effect = nil;
}

- (void)draw {
    [self.effect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 36);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self config];
    [self effect];
    [self addVertexAndNormal];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self clear];
    [self draw];
}

// 此接口是重写父类的,但是我没找到在哪里
- (void)update {
    [self changeTrack];
}

- (void)dealloc {
    [self teardownGL];
    if (EAGLContext.currentContext == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)config {
    GLKView *temp = (GLKView *)self.view;
    temp.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    temp.context = self.context;
}

- (EAGLContext *)context {
    if (_context == nil) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        [EAGLContext setCurrentContext:_context];
    }
    return _context;
}

- (GLKBaseEffect *)effect {
    if (_effect == nil) {
        _effect = [[GLKBaseEffect alloc] init];
        _effect.light0.enabled = YES;
        _effect.light0.diffuseColor = GLKVector4Make(0.5, 0.1, 0.4, 1);
    }
    return _effect;
}



@end
