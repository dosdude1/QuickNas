//
//  Server.m
//  QuickNas
//
//  Created by Collin Mistr on 11/10/16.
//  Copyright (c) 2016 dosdude1 Apps. All rights reserved.
//

#import "Server.h"

@implementation Server

-(id)init
{
    return self;
}
-(instancetype)initWithName:(NSString *)inName withType:(NSString *)inType withIP:(NSString *)inIP withUsername:(NSString *)inUserName withPassword:(NSString *)inPassword connectAtLaunch:(BOOL)connectAtLaunch atMountpoint:(NSString *)inMountPoint
{
    name=inName;
    type=inType;
    ip=inIP;
    userName=inUserName;
    password=inPassword;
    shouldConnectAtLaunch=connectAtLaunch;
    mountPoint=inMountPoint;
    return self;
}

#pragma mark Public Methods

-(NSString *)getName
{
    return name;
}
-(NSString *)getType
{
    return type;
}
-(NSString *)getIP
{
    return ip;
}
-(NSString *)getUsername
{
    return userName;
}
-(NSString *)getPassword
{
    return password;
}
-(BOOL)shouldConnectAtLaunch
{
    return shouldConnectAtLaunch;
}
-(NSString *)getMountPoint
{
    return mountPoint;
}


-(void)connect
{
    NSString *scriptToExecute=@"";
    BOOL proceed=YES;
    if ([type isEqualToString:@"afp"])
    {
        scriptToExecute=[NSString stringWithFormat:@"mount -t afp afp://%@:%@@%@ %@", userName, password, ip, mountPoint];
    }
    else if ([type isEqualToString:@"smbfs"])
    {
        scriptToExecute=[NSString stringWithFormat:@"mount -t smbfs smb://%@:%@@%@ %@", userName, password, ip, mountPoint];
    }
    if (![[NSFileManager defaultManager]fileExistsAtPath:mountPoint])
    {
        proceed=NO;
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Mountpoint Doesn't Exist"];
        [alert setInformativeText:@"The mountpoint at \"%@\" doesn't exist. Would you like to create this directory?"];
        [alert addButtonWithTitle:@"Yes"];
        [alert addButtonWithTitle:@"No"];
        if ([alert runModal]==NSAlertFirstButtonReturn)
        {
            [[NSFileManager defaultManager]createDirectoryAtPath:mountPoint withIntermediateDirectories:YES attributes:nil error:nil];
            proceed=YES;
        }
    }
    if (proceed)
    {
        NSDictionary *error=nil;
        NSAppleScript *scpt=[[NSAppleScript alloc]initWithSource:[NSString stringWithFormat:@"do shell script\"%@\"", scriptToExecute]];
        [scpt executeAndReturnError:&error];
        if (error)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"Alert"];
            [alert setInformativeText:[error objectForKey:@"NSAppleScriptErrorMessage"]];
            [alert addButtonWithTitle:@"OK"];
            [alert performSelectorOnMainThread:@selector(runModal) withObject:nil waitUntilDone:YES];
        }
    }
}
@end
