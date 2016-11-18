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
    NSString *type;
    NSString *userName;
    NSString *password;
    NSString *mountPoint;
    BOOL shouldConnectAtLaunch;
}
-(id)init;
-(instancetype)initWithName:(NSString *)inName withType:(NSString *)inType withIP:(NSString *)inIP withUsername:(NSString *)inUserName withPassword:(NSString *)inPassword connectAtLaunch:(BOOL)connectAtLaunch atMountpoint:(NSString *)inMountPoint;

#pragma mark Getter Methods

-(NSString *)getName;
-(NSString *)getType;
-(NSString *)getIP;
-(NSString *)getUsername;
-(NSString *)getPassword;
-(NSString *)getMountPoint;
-(BOOL)shouldConnectAtLaunch;
-(void)connect;
@end
