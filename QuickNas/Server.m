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
-(instancetype)initWithName:(NSString *)inName withType:(NSString *)inType withIP:(NSString *)inIP withPort:(NSString *)inPort withUsername:(NSString *)inUserName withPassword:(NSString *)inPassword connectAtLaunch:(BOOL)connectAtLaunch atMountpoint:(NSString *)inMountPoint inWorkgroup:(NSString *)inWorkgroup
{
    resourcePath = [[NSBundle mainBundle]resourcePath];
    name=inName;
    type=inType;
    ip=inIP;
    port=inPort;
    userName=inUserName;
    password=inPassword;
    shouldConnectAtLaunch=connectAtLaunch;
    mountPoint=inMountPoint;
    workgroup=inWorkgroup;
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
-(NSString *)getPort
{
    return port;
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
-(NSString *)getWorkgroup
{
    return workgroup;
}
-(void)connect
{
    NSArray *args;
    if ([type isEqualToString:@"afp"])
    {
        if ([port isEqualToString:@""])
        {
            args=[[NSArray alloc]initWithObjects:@"-t", type, [[[[[[type stringByAppendingString:@"://"]stringByAppendingString:userName]stringByAppendingString:@":"]stringByAppendingString:password]stringByAppendingString:@"@"]stringByAppendingString:ip], mountPoint, nil];
        }
        else
        {
            args=[[NSArray alloc]initWithObjects:@"-t", type, [[[[[[[[type stringByAppendingString:@"://"]stringByAppendingString:userName]stringByAppendingString:@":"]stringByAppendingString:password]stringByAppendingString:@"@"]stringByAppendingString:ip] stringByAppendingString:@":"]stringByAppendingString:port], mountPoint, nil];
        }
    }
    else if ([type isEqualToString:@"smbfs"])
    {
        if ([port isEqualToString:@""])
        {
            /*args=[[NSArray alloc]initWithObjects:@"-t", type, [[[[[[[[[@"smb://" stringByAppendingString:@"\'"]stringByAppendingString:workgroup] stringByAppendingString:@";"] stringByAppendingString:userName]stringByAppendingString:@":"]stringByAppendingString:password] stringByAppendingString:@"\'"] stringByAppendingString:@"@"]stringByAppendingString:ip], mountPoint, nil];*/
            args=[NSArray arrayWithObjects:@"-t", @"smbfs", @"smb://\'WORKGROUP;Administrator:Wewillburythem2016\'@192.168.1.6/Apps", @"/Users/collinmistr/Desktop/test",nil];
        }
        else
        {
            //args=[[NSArray alloc]initWithObjects:@"-t", type, [[[[[[[[[[[@"smb://" stringByAppendingString:@"\'"]stringByAppendingString:workgroup] stringByAppendingString:@";"] stringByAppendingString:userName]stringByAppendingString:@":"]stringByAppendingString:password] stringByAppendingString:@"\'"] stringByAppendingString:@"@"]stringByAppendingString:ip] stringByAppendingString:@":"]stringByAppendingString:port], mountPoint, nil];
        }
    }
    OptionBits flags = 0;
    NSURL * url = [NSURL URLWithString: @"afp://192.168.1.143/collinmistr"];
    //NSURL * mountDir = [NSURL URLWithString: @"/Users/collinmistr/Desktop/test"];
    
    OSStatus err = FSMountServerVolumeSync (
                             (__bridge CFURLRef) url,
                             nil,
                             (CFStringRef) @"collinmistr",
                             (CFStringRef) @"guest",
                             nil,
                             flags);
    if (err != noErr)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Error"];
        [alert setInformativeText:[NSString stringWithFormat:@"%d", err]];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    /*NSTask *connect=[[NSTask alloc]init];
    [connect setLaunchPath:@"/sbin/mount"];
    [connect setArguments:args];
    NSPipe * out = [NSPipe pipe];
    [connect setStandardError:out];
    [connect launch];
    [connect waitUntilExit];
    NSFileHandle * read = [out fileHandleForReading];
    NSData * dataRead = [read readDataToEndOfFile];
    NSString * stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
    if (![stringRead isEqualToString:@""])
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Error"];
        [alert setInformativeText:stringRead];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }*/
    
}
@end
