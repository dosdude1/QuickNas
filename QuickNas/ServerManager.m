//
//  ServerManager.m
//  QuickNas
//
//  Created by Collin Mistr on 11/10/16.
//  Copyright (c) 2016 dosdude1 Apps. All rights reserved.
//

#import "ServerManager.h"

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
-(void)getMenuItems:(NSStatusItem *)inStatusItem withMenu:(NSMenu *)inMenu
{
    statusItem=inStatusItem;
    mainMenu=inMenu;
}
#pragma mark Helper Methods

-(void)initServers
{
    servers = [[NSMutableArray alloc]init];
    if (serverList.count>0)
    {
        for (int i=0; i<serverList.count; i++)
        {
            [servers addObject:[[Server alloc]initWithName:[[serverList objectAtIndex:i]objectForKey:@"name"] withType:[[serverList objectAtIndex:i]objectForKey:@"type"] withIP:[[serverList objectAtIndex:i]objectForKey:@"IP"] withUsername:[[serverList objectAtIndex:i]objectForKey:@"username"] withPassword:[[serverList objectAtIndex:i]objectForKey:@"password"]connectAtLaunch:[[[serverList objectAtIndex:i]objectForKey:@"connectAtLaunch"]boolValue]atMountpoint:[[serverList objectAtIndex:i]objectForKey:@"mountpoint"]]];
        }
    }
}
-(void)saveData
{
    [serverList removeAllObjects];
    for (int i=0; i<servers.count; i++)
    {
        [serverList addObject:[[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:[[servers objectAtIndex:i]getName], [[servers objectAtIndex:i]getType], [[servers objectAtIndex:i]getIP], [[servers objectAtIndex:i]getUsername], [[servers objectAtIndex:i]getPassword], [NSNumber numberWithBool:[[servers objectAtIndex:i]shouldConnectAtLaunch]], [[servers objectAtIndex:i]getMountPoint], nil] forKeys:[NSArray arrayWithObjects:@"name", @"type", @"IP", @"username", @"password", @"connectAtLaunch", @"mountpoint", nil]]];
    }
    [serverList writeToFile:[applicationSupportDirectory stringByAppendingPathComponent:@"QuickNas/servers.plist"] atomically:YES];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"didChangeSettings" object:nil];
}
-(void)connectInBackground:(NSNumber *)serverIndex
{
    [self setUI];
    [self performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:YES];
    [[servers objectAtIndex:[serverIndex intValue]]connect];
    [self performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
    [self resetUI];
}
-(void)connectServersInBackgroundWithIndices:(NSArray *)indices
{
    [self setUI];
    [self performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:YES];
    for (int i=0; i<indices.count; i++)
    {
        int t=[[indices objectAtIndex:i]intValue];
        [[servers objectAtIndex:t] connect];
    }
    [self performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
    [self resetUI];
}
- (void)startAnimating
{
    currentFrame = 0;
    animTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(updateImage:) userInfo:nil repeats:YES];
}

- (void)stopAnimating
{
    [animTimer invalidate];
    [statusItem setImage:[NSImage imageNamed:@"nas-16.png"]];
}

- (void)updateImage:(NSTimer*)timer
{
    [statusItem setImage:[NSImage imageNamed:[NSString stringWithFormat:@"%d",currentFrame]]];
    currentFrame++;
    if (currentFrame % 45 == 0) {
        currentFrame = 0;
    }
}
-(void)connectAllServersInBackground
{
    [self setUI];
    [self performSelectorOnMainThread:@selector(startAnimating) withObject:nil waitUntilDone:YES];
    for (int i=0; i<servers.count; i++)
    {
        [[servers objectAtIndex:i]connect];
    }
    [self performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
    [self resetUI];
}
-(void)setUI
{
    [[mainMenu itemAtIndex:0]setEnabled:NO];
    [[mainMenu itemAtIndex:1]setEnabled:NO];
    [[mainMenu itemAtIndex:2]setEnabled:NO];
}
-(void)resetUI
{
    [[mainMenu itemAtIndex:0]setEnabled:YES];
    [[mainMenu itemAtIndex:1]setEnabled:YES];
    [[mainMenu itemAtIndex:2]setEnabled:YES];
}
#pragma mark Public Methods


-(void)addServer:(NSString *)name ofType:(NSString *)serverType withIP:(NSString *)ipIn withUsername:(NSString *)userName withPassword:(NSString *)password connectAtLaunch:(BOOL)connectAtLaunch atMountPoint:(NSString *)inMountPoint
{
    [servers addObject:[[Server alloc]initWithName:name withType:serverType withIP:ipIn withUsername:userName withPassword:password connectAtLaunch:connectAtLaunch atMountpoint:inMountPoint]];
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
-(void)connectServer:(int)index
{
    [self performSelectorInBackground:@selector(connectInBackground:) withObject:[NSNumber numberWithInt:index]];
}
-(NSInteger)getNumServers
{
    return [servers count];
}
-(void)setServer:(NSInteger)toSet withName:(NSString *)name ofType:(NSString *)serverType withIP:(NSString *)ipIn withUsername:(NSString *)userName withPassword:(NSString *)password connectAtLaunch:(BOOL)connectAtLaunch atMountPoint:(NSString *)inMountPoint
{
    [servers replaceObjectAtIndex:toSet withObject:[[Server alloc]initWithName:name withType:serverType withIP:ipIn withUsername:userName withPassword:password connectAtLaunch:connectAtLaunch atMountpoint:inMountPoint]];
    [self saveData];
}
-(void)connectAllServers
{
    [self performSelectorInBackground:@selector(connectAllServersInBackground) withObject:nil];
}
-(void)connectServersWithIndices:(NSArray *)indices
{
    [self performSelectorInBackground:@selector(connectServersInBackgroundWithIndices:) withObject:indices];
}

@end
