//
//  Sand.m
//  iOS App Dev
//
//  Created by Lion User on 25/09/2013.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
// Used http://www.raywenderlich.com/32954/how-to-create-a-game-like-tiny-wings-with-cocos2d-2-x-part-1
// for the ground, but since he uses box2d for collisions we had to do that for the collisions. TODO: refactor into configuration file, there are a lot of magic numbers which we can tweak for nicer sand.
//

#import "Sand.h"
#import "ChipmunkAutoGeometry.h"

@implementation Sand

- (id)initWithSpace:(ChipmunkSpace *) space {
    self = [super init];
    if (self)
    {
        _space = space;
        _winSize = [CCDirector sharedDirector].winSize;
        // Load configuration file
        _configuration = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Configurations" ofType:@"plist"]];
        self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTexture];
        [self generateHills:0.0f];
        [self resetHillVertices];
    }
    return self;
}

- (void)resetHillVertices {
    static int prevFromKeyPointI = -1;
    static int prevToKeyPointI = -1;
    
    // key points interval for drawing
    while (_hillKeyPoints[_fromKeyPointI+1].x < _offsetX-_winSize.width*4/8/self.scale) {
        _fromKeyPointI++;
    }
    while (_hillKeyPoints[_toKeyPointI].x < _offsetX+_winSize.width*8/8/self.scale) {
        _toKeyPointI++;
    }
    
    float minY = 0;
    if (_winSize.height > 480) {
        minY = (1136 - 1024)/4;
    }
    if (prevFromKeyPointI != _fromKeyPointI || prevToKeyPointI != _toKeyPointI) {
        
        // vertices for visible area
        _nHillVertices = 0;
        _nBorderVertices = 0;
        CGPoint p0, p1, pt0, pt1;
        p0 = _hillKeyPoints[_fromKeyPointI];
        for (int i=_fromKeyPointI+1; i<=_toKeyPointI; i++) {
            p1 = _hillKeyPoints[i];
            
            /*if(p1.x-p0.x >300){
                p0.x = p1.x-140;
                p0.y = p1.y;
            }*/
            // triangle strip between p0 and p1
            int hSegments = floorf((p1.x-p0.x)/kHillSegmentWidth);
            float dx = (p1.x - p0.x) / hSegments;
            float da = M_PI / hSegments;
            float ymid = (p0.y + p1.y) / 2;
            float ampl = (p0.y - p1.y) / 2;
            pt0 = p0;
            //_borderVertices[_nBorderVertices++] = pt0; Had to comment this out so that the collision handling would work, this adds the base points between hills, and then the collision happens twice at the same point and the octopus gets warped to position {nan,nan}
            for (int j=1; j<hSegments+1; j++) {
                pt1.x = p0.x + j*dx;
                pt1.y = ymid + ampl * cosf(da*j);
                _borderVertices[_nBorderVertices++] = pt1;
                
                _hillVertices[_nHillVertices] = CGPointMake(pt0.x, 0 + minY);
                _hillTexCoords[_nHillVertices++] = CGPointMake(pt0.x/512, 1.0f);
                _hillVertices[_nHillVertices] = CGPointMake(pt1.x, 0 + minY);
                _hillTexCoords[_nHillVertices++] = CGPointMake(pt1.x/512, 1.0f);
                
                _hillVertices[_nHillVertices] = CGPointMake(pt0.x, pt0.y);
                _hillTexCoords[_nHillVertices++] = CGPointMake(pt0.x/512, 0);
                _hillVertices[_nHillVertices] = CGPointMake(pt1.x, pt1.y);
                _hillTexCoords[_nHillVertices++] = CGPointMake(pt1.x/512, 0);
                
                pt0 = pt1;
            }
            
            p0 = p1;
        }
        
        prevFromKeyPointI = _fromKeyPointI;
        prevToKeyPointI = _toKeyPointI;
        [self generateBody];
    }
}

- (void) draw {
    CC_NODE_DRAW_SETUP();
    
    ccGLBindTexture2D(_stripes.texture.name);
    ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_TexCoords);
    
    ccDrawColor4F(1.0f, 1.0f, 1.0f, 1.0f);
    glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, _hillVertices);
    glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, _hillTexCoords);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)_nHillVertices);
    
    /*for(int i = MAX(_fromKeyPointI, 1); i <= _toKeyPointI; ++i) {
        ccDrawColor4F(1.0, 0, 0, 1.0);
        ccDrawLine(_hillKeyPoints[i-1], _hillKeyPoints[i]);
        ccDrawColor4F(1.0, 1.0, 1.0, 1.0);
        
        CGPoint p0 = _hillKeyPoints[i-1];
        CGPoint p1 = _hillKeyPoints[i];
        int hSegments = floorf((p1.x-p0.x)/kHillSegmentWidth);
        float dx = (p1.x - p0.x) / hSegments;
        float da = M_PI / hSegments;
        float ymid = (p0.y + p1.y) / 2;
        float ampl = (p0.y - p1.y) / 2;
        
        CGPoint pt0, pt1;
        pt0 = p0;
        for (int j = 0; j < hSegments+1; ++j) {
            
            pt1.x = p0.x + j*dx;
            pt1.y = ymid + ampl * cosf(da*j);
            
            ccDrawLine(pt0, pt1);
            
            pt0 = pt1;
            
        }
    }*/
    
}
- (void) generateBody {
    if(_body)
    {
        for (ChipmunkShape *shape in _body.shapes){
            [_space smartRemove:shape];
        }
    }
    //Make a polyline, mallocing the pointersize.
    cpPolyline *rolypoly = (cpPolyline *)malloc(sizeof(cpPolyline));
    //set capacity.
    rolypoly->capacity = kMaxBorderVertices;
    //set the count of vertices currently.
    rolypoly->count = _nBorderVertices;
    //Mallocing a copy of _borderVertices.
    CGPoint *vertz = (CGPoint *)malloc(sizeof(_borderVertices));
    //Memcpy _borderVertices to vertz
    memcpy(vertz, _borderVertices,sizeof(_borderVertices));
    //Set the polyline verts as vertz
    rolypoly->verts = vertz;
    //Make a new ChipmunkPolyline from a polyline, the polyline is then destroyed, that is why we had to malloc the copy of the vertices.
    ChipmunkPolyline *simpleLine = [ChipmunkPolyline fromPolyline: *rolypoly ];
    _body = [ChipmunkBody staticBody];
    //make a shapes array from the line we created.
    NSArray *bodyShapes = [simpleLine asChipmunkSegmentsWithBody:_body radius:0 offset:cpvzero];
    for (ChipmunkShape *shape in bodyShapes)
    {
        shape.friction = 100.0f;
        [_space addShape:shape];
    }
}

- (void) generateHills:(float)startX {
    
    float minDX = [_configuration[@"sandMinDX"]floatValue];
    float minDY = [_configuration[@"sandMinDY"]floatValue];
    int rangeDX = [_configuration[@"sandRangeDX"]intValue];
    int rangeDY = [_configuration[@"sandRangeDY"]intValue];
    _fromKeyPointI = 0;
    _toKeyPointI = 0;
    float x = startX;
    float y = _winSize.height/4;
    
    float dy, ny;
    float sign = 1; // +1 - going up, -1 - going  down
    float paddingTop = _winSize.height/4;
    float paddingBottom = _winSize.height/20;
    
    for (int i=0; i<kMaxHillKeyPoints; i++) {
        _hillKeyPoints[i] = CGPointMake(x, y);
        if (i == 0) {
            x = startX;
            y = _winSize.height/4;
        } else {
            x += rand()%rangeDX+minDX;
            //while(true) {
                dy = rand()%rangeDY+minDY;
                ny = y + dy*sign;
                if(ny<paddingBottom)
                    ny = paddingBottom;
                if(ny>paddingTop)
                    ny = paddingTop;
                /*if(ny < _winSize.height-paddingTop && ny > paddingBottom) {
                    break;
                }
            }*/
            y = ny;
        }
        sign *= -1;
    }
}

- (void) setOffsetX:(float)newOffsetX {
    _offsetX = newOffsetX;
    //self.position = CGPointMake(-_offsetX*self.scale, 0);
    [self resetHillVertices];
    if(_fromKeyPointI>900||_toKeyPointI>900)
    {
        [self generateHills:_offsetX];
    }
}

/*- (void)dealloc {
    [_stripes release];
    _stripes = NULL;
    [super dealloc];
}*/
@end
