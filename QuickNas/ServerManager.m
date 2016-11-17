//
//  ServerManager.m
//  QuickNas
//
//  Created by Collin Mistr on 11/10/16.
//  Copyright (c) 2016 dosdude1 Apps. All rights reserved.
//

#import "ServerManager.h"
#import "Server.h"

@implementation ServerManager

-(id)init
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    applicationSupportDirectory = [paths firstObject];
    if (![[NSFileManager defaultManager]fileExistsAtPath:[applicationSupportDirectory stringByAppendingPathComponent:@"QuickNas"]])
    {
        [[NSFileManager defaultManager]createDirectoryAtPath:[applicationSupportDirectory stringByAppendingPathComponent:@"QuickNas"] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if ([[NSFileManager defaultManager]fileExistsAtPath:[applicationSupportDirectory stringByAppendingPathComponent:@"QuickNas/servers.plist"]])
    {
        serverList = [[NSMutableArray alloc]initWithContentsOfFile:[applicationSupportDirectory stringByAppendingPathComponent:@"QuickNas/servers.plist"]];
    }
    else
    {
        serverList=[[NSMutableArray alloc]init];
    }
    [self initServers];
    return self;
}

#pragma mark Helper Methods

-(void)initServers
{
    servers = [[NSMutableArray alloc]init];
    if (serverList.count>0)
    {
        for (int i=0; i<serverList.count; i++)
        {
            [servers addObject:[[Server alloc]initWithName:[[serverList objectAtIndex:i]objectForKey:@"name"] withType:[[serverList objectAtIndex:i]objectForKey:@"type"] withIP:[[serverList objectAtIndex:i]objectForKey:@"IP"] withPort:[[serverList objectAtIndex:i]objectForKey:@"port"] withUsername:[[serverList objectAtIndex:i]objectForKey:@"username"] withPassword:[[serverList objectAtIndex:i]objectForKey:@"password"]connectAtLaunch:[[[serverList objectAtIndex:i]objectForKey:@"connectAtLaunch"]boolValue]atMountpoint:[[serverList objectAtIndex:i]objectForKey:@"mountpoint"] inWorkgroup:[[serverList objectAtIndex:i]objectForKey:@"workgroup"]]];
        }
    }
}
-(void)saveData
{
    [serverList removeAllObjects];
    for (int i=0; i<servers.count; i++)
    {
        [serverList addObject:[[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:[[servers objectAtIndex:i]getName], [[servers objectAtIndex:i]getType], [[servers objectAtIndex:i]getIP], [[servers objectAtIndex:i]getPort], [[servers objectAtIndex:i]getUsername], [[servers objectAtIndex:i]getPassword], [NSNumber numberWithBool:[[servers objectAtIndex:i]shouldConnectAtLaunch]], [[servers objectAtIndex:i]getMountPoint], [[servers objectAtIndex:i]getWorkgroup], nil] forKeys:[NSArray arrayWithObjects:@"name", @"type", @"IP", @"port", @"username", @"password", @"connectAtLaunch", @"mountpoint", @"workgroup", nil]]];
    }
    [serverList writeToFile:[applicationSupportDirectory stringByAppendingPathComponent:@"QuickNas/servers.plist"] atomically:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"didChangeSettings" object:nil];
}


#pragma mark Public Methods


-(void)addServer:(NSString *)name ofType:(NSString *)serverType withIP:(NSString *)ipIn withPort:(NSString *)port withUsername:(NSString *)userName withPassword:(NSString *)password connectAtLaunch:(BOOL)connectAtLaunch atMountPoint:(NSString *)inMountPoint inWorkgroup:(NSString *)inWorkgroup
{
    [servers addObject:[[Server alloc]initWithName:name withType:serverType withIP:ipIn withPort:port withUsername:userName withPassword:password connectAtLaunch:connectAtLaunch atMountpoint:inMountPoint inWorkgroup:inWorkgroup]];
    [self saveData];
}
-(void)removeServer:(int)toRemove
{
    [servers removeObjectAtIndex:toRemove];
    [self saveData];
}
-(Server *)getServer:(int)index
{
    return [servers objectAtIndex:index];
}
-(NSInteger)getNumServers
{
    return [servers count];
}
-(void)setServer:(NSInteger)toSet withName:(NSString *)name ofType:(NSString *)serverType withIP:(NSString *)ipIn withPort:(NSString *)port withUsername:(NSString *)userName withPassword:(NSString *)password connectAtLaunch:(BOOL)connectAtLaunch atMountPoint:(NSString *)inMountPoint inWorkgroup:(NSString *)inWorkgroup
{
    [servers replaceObjectAtIndex:toSet withObject:[[Server alloc]initWithName:name withType:serverType withIP:ipIn withPort:port withUsername:userName withPassword:password connectAtLaunch:connectAtLaunch atMountpoint:inMountPoint inWorkgroup:inWorkgroup]];
    [self saveData];
}
@end
