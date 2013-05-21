//
//  HelloWorldLayer.m
//  isometric test
//
//  Created by Ruben Flores on 5/20/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
        
        self.isTouchEnabled = YES;
        
       // [self setIgnoreAnchorPointForPosition:NO];
		
        map = [CCTMXTiledMap tiledMapWithTMXFile:@"isometric.tmx"];
        
        CCTMXLayer *layer = [map layerNamed:@"layer"];
        
        CCSprite *tile = [layer tileAt:ccp(24,24)];
        
        
        CCLOG(@"point %.2f , %.2f", tile.position.x, tile.position.y);
        
//        point = [[CCDirector sharedDirector] convertToGL:point];
//        
//        CCLOG(@"GL%.2f , %.2f", point.x, point.y);
        
//        point = [self convertToNodeSpace:point];
//        
//        CCLOG(@"NODE %.2f , %.2f", point.x, point.y);
        
        CCLOG(@"Map width: %.2f" , map.mapSize.width);
        CCLOG(@"Tile width: %.2f", map.tileSize.width);
        
        CGPoint p = ccp((map.mapSize.width * map.tileSize.width) / 2,0);
        
        CCLOG(@"P : %.2f , %.2f", p.x, p.y);

        [map setPosition:ccp(-500,-300)];

        [self addChild:map];
        
        
        
        CCLOG(@"LP : %.2f , %.2f", self.position.x, self.position.y);
        


	}
	return self;
}

-(void)registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self
                                                              priority:0
                                                       swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    previous = [touch locationInView:touch.view];
    
    previous = [[CCDirector sharedDirector] convertToGL:previous];
    
	return YES;
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
//    CGPoint touchlocation = [touch locationInView:touch.view];
//    
//    touchlocation = [[CCDirector sharedDirector] convertToGL:touchlocation];
//
//    touchlocation = [self convertToNodeSpace:touchlocation];
//        
//    CGPoint tileCoord = [self tilePosFromLocation:touchlocation tileMap:map];
//    
//    CCLOG(@"Tile coord: <%.2f , %.2f>", tileCoord.x, tileCoord.y);
    
    CGPoint mapPos = [map position];
    
    CCLOG(@"Map: <%.2f, %.2f>", mapPos.x, mapPos.y);
    
//    [self centerTileMapOnTileCoord:tileCoord tileMap:map];

}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint mapLoc = [map position];
    
    CGPoint touchlocation = [touch locationInView:touch.view];
        
    touchlocation = [[CCDirector sharedDirector] convertToGL:touchlocation];
    
    CGPoint delta = ccpSub(touchlocation, previous);
    
    mapLoc = ccpAdd(mapLoc, delta);
    
    if( mapLoc.x > 0 || mapLoc.y > 0 || mapLoc.x < -1300 || mapLoc.y < -330)
        return;
    
    [map setPosition:mapLoc];
    
    previous = touchlocation;
}

-(CGPoint) tilePosFromLocation:(CGPoint)location tileMap:(CCTMXTiledMap*)tileMap
{
    // Tilemap position must be subtracted, in case the tilemap position is scrolling
    CGPoint pos = ccpSub(location, tileMap.position);
    
    float halfMapWidth = tileMap.mapSize.width * 0.5f;
    float mapHeight = tileMap.mapSize.height;
    float tileWidth = tileMap.tileSize.width;
    float tileHeight = tileMap.tileSize.height;
    
    CGPoint tilePosDiv = CGPointMake(pos.x / tileWidth, pos.y / tileHeight);
    float inverseTileY = mapHeight - tilePosDiv.y;
    
    // Cast to int makes sure that result is in whole numbers
    float posX = (int)(inverseTileY + tilePosDiv.x - halfMapWidth);
    float posY = (int)(inverseTileY - tilePosDiv.x + halfMapWidth);
    
    // make sure coordinates are within isomap bounds
    posX = MAX(0, posX);
    posX = MIN(tileMap.mapSize.width - 1, posX);
    posY = MAX(0, posY);
    posY = MIN(tileMap.mapSize.height - 1, posY);
    
    return CGPointMake(posX, posY);
}

-(void) centerTileMapOnTileCoord:(CGPoint)tilePos tileMap:(CCTMXTiledMap*)tileMap
{
    // center tilemap on the given tile pos
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    CGPoint screenCenter = CGPointMake(screenSize.width * 0.5f,
                                       screenSize.height * 0.5f);
    
    // get the ground layer
    CCTMXLayer* layer = [tileMap layerNamed:@"layer"];
    NSAssert(layer != nil, @"Ground layer not found!");
    
    // internally tile Y coordinates are off by 1
    tilePos.y -= 1;
    
    // get the pixel coordinates for a tile at these coordinates
    CGPoint scrollPosition = [layer positionAt:tilePos];
    
    // negate the position to account for scrolling
    scrollPosition = ccpMult(scrollPosition, -1);
    
    // add offset to screen center
    scrollPosition = ccpAdd(scrollPosition, screenCenter);
    
    // move the tilemap
    CCAction* move = [CCMoveTo actionWithDuration:0.2f position:scrollPosition];
    [tileMap stopAllActions];
    [tileMap runAction:move];
}

-(void) updateMapCoord:(CGPoint)tilePos tileMap:(CCTMXTiledMap*)tileMap
{
    // center tilemap on the given tile pos
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    CGPoint screenCenter = CGPointMake(screenSize.width * 0.5f,
                                       screenSize.height * 0.5f);
    
    // get the ground layer
    CCTMXLayer* layer = [tileMap layerNamed:@"layer"];
    NSAssert(layer != nil, @"Ground layer not found!");
    
    // internally tile Y coordinates are off by 1
    tilePos.y -= 1;
    
    // get the pixel coordinates for a tile at these coordinates
    CGPoint scrollPosition = [layer positionAt:tilePos];
    
    // negate the position to account for scrolling
    scrollPosition = ccpMult(scrollPosition, -1);
    
    // add offset to screen center
    scrollPosition = ccpAdd(scrollPosition, screenCenter);
    
    // move the tilemap
    [map setPosition:scrollPosition];
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
