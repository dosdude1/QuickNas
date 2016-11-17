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
}
-(id)init;
-(void)addServer:(NSString *)name ofType:(NSString *)serverType withIP:(NSString *)ipIn withPort:(NSString *)port withUsername:(NSString *)userName withPassword:(NSString *)password connectAtLaunch:(BOOL)connectAtLaunch atMountPoint:(NSString *)inMountPoint inWorkgroup:(NSString *)inWorkgroup;
-(void)removeServer:(int)toRemove;
-(Server *)getServer:(int)index;
-(NSInteger)getNumServers;
-(void)setServer:(NSInteger)toSet withName:(NSString *)name ofType:(NSString *)serverType withIP:(NSString *)ipIn withPort:(NSString *)port withUsername:(NSString *)userName withPassword:(NSString *)password connectAtLaunch:(BOOL)connectAtLaunch atMountPoint:(NSString *)inMountPoint inWorkgroup:(NSString *)inWorkgroup;
@end
