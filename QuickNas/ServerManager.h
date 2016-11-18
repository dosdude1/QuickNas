//
//  ServerManager.h
//  QuickNas
//
//  Created by Collin Mistr on 11/10/16.
//  Copyright (c) 2016 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Server.h"

@interface ServerManager : NSObject
{
    NSString *applicationSupportDirectory;
    NSMutableArray *serverList;
    NSMutableArray *servers;
    int numServerToConnect;
    NSStatusItem *statusItem;
    NSMenu *mainMenu;
    int currentFrame;
    NSTimer *animTimer;
    int serverToConnect;
}
-(id)init;
-(void)getMenuItems:(NSStatusItem *)inStatusItem withMenu:(NSMenu *)inMenu;
-(void)addServer:(NSString *)name ofType:(NSString *)serverType withIP:(NSString *)ipIn withUsername:(NSString *)userName withPassword:(NSString *)password connectAtLaunch:(BOOL)connectAtLaunch atMountPoint:(NSString *)inMountPoint;
-(void)removeServer:(int)toRemove;
-(Server *)getServer:(int)index;
-(void)connectServer:(int)index;
-(NSInteger)getNumServers;
-(void)setServer:(NSInteger)toSet withName:(NSString *)name ofType:(NSString *)serverType withIP:(NSString *)ipIn withUsername:(NSString *)userName withPassword:(NSString *)password connectAtLaunch:(BOOL)connectAtLaunch atMountPoint:(NSString *)inMountPoint;
-(void)connectAllServers;
-(void)connectServersWithIndices:(NSArray *)indices;
@end
