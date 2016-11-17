//
//  Server.h
//  QuickNas
//
//  Created by Collin Mistr on 11/10/16.
//  Copyright (c) 2016 dosdude1 Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreServices/CoreServices.h>

@interface Server : NSObject
{
    NSString *name;
    NSString *ip;
    NSString *port;
    NSString *type;
    NSString *userName;
    NSString *password;
    NSString *mountPoint;
    NSString *workgroup;
    BOOL shouldConnectAtLaunch;
    NSString *resourcePath;
}
-(id)init;
-(instancetype)initWithName:(NSString *)inName withType:(NSString *)inType withIP:(NSString *)inIP withPort:(NSString *)inPort withUsername:(NSString *)inUserName withPassword:(NSString *)inPassword connectAtLaunch:(BOOL)connectAtLaunch atMountpoint:(NSString *)inMountPoint inWorkgroup:(NSString *)inWorkgroup;

#pragma mark Getter Methods

-(NSString *)getName;
-(NSString *)getType;
-(NSString *)getIP;
-(NSString *)getPort;
-(NSString *)getUsername;
-(NSString *)getPassword;
-(NSString *)getMountPoint;
-(BOOL)shouldConnectAtLaunch;
-(NSString *)getWorkgroup;
-(void)connect;
@end
