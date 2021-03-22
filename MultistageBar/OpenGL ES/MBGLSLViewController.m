//
//  MBGLSLViewController.m
//  MultistageBar
//
//  Created by x on 2021/3/18.
//  Copyright © 2021 x. All rights reserved.
//

#import "MBGLSLViewController.h"
#import <GLKit/GLKit.h>

typedef struct {
    GLKVector3 positionCoord;   // (x,y,z)
    GLKVector2 textureCoord;    // (u,v)
} SenceVertex ;

@interface MBGLSLViewController ()
@property (nonatomic, assign) SenceVertex *vertices; // 顶点数组
@property (nonatomic, strong) EAGLContext *context;
@end

@implementation MBGLSLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self commonInit];
}

- (void)commonInit {
    // 创建上下文，使用 2.0 版本
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.context];
    
    // 创建顶点数组
    self.vertices = malloc(sizeof(SenceVertex) * 4); // 4 个顶点
    
    self.vertices[0] = (SenceVertex){{-1, 1, 0}, {0, 1}}; // 左上角
    self.vertices[1] = (SenceVertex){{-1, -1, 0}, {0, 0}}; // 左下角
    self.vertices[2] = (SenceVertex){{1, 1, 0}, {1, 1}}; // 右上角
    self.vertices[3] = (SenceVertex){{1, -1, 0}, {1, 0}}; // 右下角
    
    // 创建一个展示纹理的层
    CAEAGLLayer *layer = [[CAEAGLLayer alloc] init];
    layer.frame = CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.width);
    layer.contentsScale = [[UIScreen mainScreen] scale];  // 设置缩放比例，不设置的话，纹理会失真
    
    [self.view.layer addSublayer:layer];
    
    // 绑定纹理输出的层
    [self bindRenderLayer:layer];
    
    // 读取纹理
    UIImage *image = [UIImage imageNamed:@"0"];
    GLuint textureID = [self createTextureWithImage:image];
    
    // 设置视口尺寸
    glViewport(0, 0, self.drawableWidth, self.drawableHeight);
    
    // 编译链接 shader
    
    GLuint program = [self programWithShader:@"glsl"]; // glsl.vsh & glsl.fsh
    glUseProgram(program);
    
    // 获取 shader 中的参数，然后传数据进去
    GLuint positionSlot = glGetAttribLocation(program, "Position");
    GLuint textureSlot = glGetUniformLocation(program, "Texture");  // 注意 Uniform 类型的获取方式
    GLuint textureCoordsSlot = glGetAttribLocation(program, "TextureCoords");
    
    // 将纹理 ID 传给着色器程序
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureID);
    glUniform1i(textureSlot, 0);  // 将 textureSlot 赋值为 0，而 0 与 GL_TEXTURE0 对应，这里如果写 1，上面也要改成 GL_TEXTURE1
    
    // 创建顶点缓存
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    GLsizeiptr bufferSizeBytes = sizeof(SenceVertex) * 4;
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.vertices, GL_STATIC_DRAW);
    
    // 设置顶点数据
    glEnableVertexAttribArray(positionSlot);
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));
    
    // 设置纹理数据
    glEnableVertexAttribArray(textureCoordsSlot);
    glVertexAttribPointer(textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));
    
    // 开始绘制
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    // 将绑定的渲染缓存呈现到屏幕上
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
    
    // 删除顶点缓存
    glDeleteBuffers(1, &vertexBuffer);
    vertexBuffer = 0;
}

// 绑定图像要输出的 layer
- (void)bindRenderLayer:(CALayer <EAGLDrawable> *)layer {
    GLuint renderBuffer; // 渲染缓存
    GLuint frameBuffer;  // 帧缓存
    
    // 绑定渲染缓存要输出的 layer
    glGenRenderbuffers(1, &renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    
    // 将渲染缓存绑定到帧缓存上
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER,
                              GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER,
                              renderBuffer);
}

- (GLuint)createTextureWithImage:(UIImage *)image {
    CGImageRef imgRef = image.CGImage;
    GLuint width = (GLuint)CGImageGetWidth(imgRef);
    GLuint height = (GLuint)CGImageGetHeight(imgRef);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    void *imgData = malloc(width * height * 4);
    uint32_t bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    CGContextRef context = CGBitmapContextCreate(imgData, width, height, 8, width * 4, colorspace, bitmapInfo);
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGColorSpaceRelease(colorspace);
    CGContextClearRect(context, rect);
    CGContextDrawImage(context, rect, imgRef);
    
    GLuint textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imgData);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    CGContextRelease(context);
    free(imgData);
    
    return  textureID;
}

- (GLuint)compileShaderWithName:(NSString *)name type:(GLenum)shaderType {
    NSString *path = [NSBundle.mainBundle pathForResource:name ofType:shaderType == GL_FRAGMENT_SHADER ? @"fsh" : @"vsh"];
    NSString *shaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (shaderString == NULL) {
        NSAssert(NO, @"读取shader失败");
        exit(1);
    }
    GLuint shader = glCreateShader(shaderType);
    
    const char *shaderStringUTF8 = shaderString.UTF8String;
    int shaderStringLength = shaderString.length;
    glShaderSource(shader, 1, &shaderStringUTF8, &shaderStringLength);
    
    glCompileShader(shader);
    
    GLint res;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &res);
    if (res == GL_FALSE) {
        GLchar mes[256];
        glGetShaderInfoLog(shader, sizeof(mes), 0, mes);
        NSString *str = [NSString stringWithUTF8String:mes];
        NSAssert(NO, @"shader 编译失败 \(%@)", mes);
        exit(1);
    }
    return  shader;
}

- (GLuint)programWithShader:(NSString *)name {
    GLuint vertexShader = [self compileShaderWithName:name type:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShaderWithName:name type:GL_FRAGMENT_SHADER];
    
    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    glLinkProgram(program);
    
    GLint res;
    glGetProgramiv(program, GL_LINK_STATUS, &res);
    if (res == GL_FALSE) {
        GLchar mes[256];
        glGetProgramInfoLog(program, sizeof(res), 0, &res);
        NSString *str = [NSString stringWithUTF8String:res];
        NSAssert(NO, @"program 链接失败 %@", str);
        exit(1);
    }
    return  program;
}
// 获取渲染缓存宽度
- (GLint)drawableWidth {
    GLint backingWidth;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    
    return backingWidth;
}

// 获取渲染缓存高度
- (GLint)drawableHeight {
    GLint backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    return backingHeight;
}


@end
