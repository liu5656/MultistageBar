//
//  SphereViewController.m
//  OpenGL ES
//
//  Created by x on 2021/8/19.
//

#import "SphereViewController.h"
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>


/**
 *  学习目标 绘制移动的球体
 *  https://www.jianshu.com/p/eebaf64e3e0a
 *  第一步: 创建GLKViewController 控制器(在里面实现方法)
 *  第二步: 创建EAGContext 跟踪所有状态,命令和资源
 *  第三步: 生成球体的顶点坐标和颜色数据
 *  第三步: 清除命令
 *  第四步: 创建投影坐标系
 *  第五步: 创建对象坐标
 *  第六步: 导入顶点数据
 *  第七步: 导入颜色数据
 *  第八步: 绘制
 *  欢迎加群: 578734141 交流学习~
 *
 */

@interface SphereViewController ()

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) UIImageView *bgIV;

@end

@implementation SphereViewController
{
    GLfloat *_vertexArray;
    GLubyte *_colorsArray;

    GLint  m_Stacks, m_Slices;
    GLfloat  m_Scale;
    GLfloat m_Squash;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self bgIV];

    [self config];

    [self calculate];

    [self setClipping];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self clear];
    [self initModelMatrix];
    [self loadVertexData];
    [self loadColorData];
    [self draw];
}

- (void)config {
    GLKView *temp = (GLKView *)self.view;
    temp.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    temp.context = self.context;
}

// 清除指令
- (void)clear {
    glEnable(GL_DEPTH_TEST);
    glClearColor(1, 1, 1, 0.1);
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

    static CGFloat scale = 1;
    static BOOL isBig = true;
    if (isBig){
        scale += 0.01;
    }else{
        scale -= 0.01;
    }
    if (scale>=1.5){
        isBig = false;
    }
    if (scale<=0.5){
        isBig = true;
    }
    static GLfloat transY = 0;
    static GLfloat rotateX = 0;
    static GLfloat rotateY = 0;
    glTranslatef(0, (GLfloat)(sinf(transY) / 2), -2);
    glRotatef(rotateY, 0, 1, 0);
    glRotatef(rotateX, 1, 0, 0);
    glScalef(scale, scale, scale);
    transY += 0.075;
    rotateY += 0.25;
    rotateX += 0.25;
}

// 加载顶点数据
- (void)loadVertexData {
    glVertexPointer(3, GL_FLOAT, 0, _vertexArray);
    glEnableClientState(GL_VERTEX_ARRAY);
}
// 加载颜色数据
- (void)loadColorData {
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, _colorsArray);
    glEnableClientState(GL_COLOR_ARRAY);
}

// 绘制
- (void)draw {
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, (m_Slices +1)*2*(m_Stacks-1)+2);
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



/**
 *  生成球体的顶点坐标和颜色数据
 */
-(void)calculate{
    unsigned int colorIncrment=0;                //1
    unsigned int blue=0;
    unsigned int red=255;
    unsigned int green = 0;
    static int big = 1;
    static float scale = 0;
    if (big){
       scale += 0.01;
    }else{
        scale -= 0.01;
    }


    if (scale >= 0.5){
        big = 0;
    }
    if (scale <= 0){
        big = 1;
    }
    m_Scale = 0.5 + scale;
    m_Slices = 100;
    m_Squash = 1;
    m_Stacks = 100;
    colorIncrment = 255/m_Stacks;                    //2

        //vertices
    GLfloat *vPtr =  _vertexArray = (GLfloat*)malloc(sizeof(GLfloat) * 3 * ((m_Slices*2+2) * (m_Stacks)));    //3

        //color data
    GLubyte *cPtr = _colorsArray = (GLubyte*)malloc(sizeof(GLubyte) * 4 * ((m_Slices *2+2) * (m_Stacks)));    //4

    unsigned int    phiIdx, thetaIdx;

    //latitude
    for(phiIdx=0; phiIdx < m_Stacks; phiIdx++)        //5
    {

        float phi0 = M_PI * ((float)(phiIdx+0) * (1.0f/(float)( m_Stacks)) - 0.5f);
        float phi1 = M_PI * ((float)(phiIdx+1) * (1.0f/(float)( m_Stacks)) - 0.5f);
        float cosPhi0 = cos(phi0);            //8
        float sinPhi0 = sin(phi0);
        float cosPhi1 = cos(phi1);
        float sinPhi1 = sin(phi1);
        float cosTheta, sinTheta;
        for(thetaIdx=0; thetaIdx < m_Slices; thetaIdx++)
        {


            float theta = 2.0f*M_PI * ((float)thetaIdx) * (1.0f/(float)( m_Slices -1));
            cosTheta = cos(theta);
            sinTheta = sin(theta);


            vPtr [0] = m_Scale*cosPhi0 * cosTheta;
            vPtr [1] = m_Scale*sinPhi0*m_Squash;
            vPtr [2] = m_Scale*cosPhi0 * sinTheta;



            vPtr [3] = m_Scale*cosPhi1 * cosTheta;
            vPtr [4] = m_Scale*sinPhi1*m_Squash;
            vPtr [5] = m_Scale* cosPhi1 * sinTheta;

            cPtr [0] = red;
            cPtr [1] = green;
            cPtr [2] = blue;
            cPtr [4] = red;
            cPtr [5] = green;
            cPtr [6] = blue;
            cPtr [3] = cPtr[7] = 255;

            cPtr += 2*4;

            vPtr += 2*3;
        }

        //blue+=colorIncrment;
        red-=colorIncrment;
       // green += colorIncrment;
        }

}



- (EAGLContext *)context {
    if (_context == nil) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        [EAGLContext setCurrentContext:_context];
    }
    return _context;
}

- (UIImageView *)bgIV {
    if (_bgIV == nil) {
        _bgIV = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _bgIV.image = [UIImage imageNamed:@"bg.jpg"];
        _bgIV.alpha = 0.5;
        [self.view addSubview:_bgIV];
    }
    return _bgIV;
}


@end
