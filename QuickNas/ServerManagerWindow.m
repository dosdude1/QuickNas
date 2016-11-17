//
//  ServerManagerWindow.m
//  QuickNas
//
//  Created by Collin Mistr on 11/10/16.
//  Copyright (c) 2016 dosdude1 Apps. All rights reserved.
//

#import "ServerManagerWindow.h"

@interface ServerManagerWindow ()

@end

@implementation ServerManagerWindow

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    didSelectRow=NO;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    applicationSupportDirectory = [paths firstObject];
    [self.serverTable setDelegate:self];
    [self.serverTable setDataSource:self];
    [self.serverTable setDoubleAction:@selector(didDoubleClickRow)];
    serverTypes = [[NSArray alloc]initWithObjects:@"Select Type...", @"afp", @"smbfs", nil];
    [self.serverTypeList addItemsWithTitles:serverTypes];
    [self.serverTypeList setAction:@selector(setOptions)];
    [self.serverTypeList setTarget:self];
}
-(void)setOptions
{
    if ([[self.serverTypeList titleOfSelectedItem]isEqualToString:@"smbfs"])
    {
        [self.workgroupField setEnabled:YES];
    }
    else
    {
        [self.workgroupField setStringValue:@""];
        [self.workgroupField setEnabled:NO];
    }
}
-(void)getServerData:(ServerManager *)inMan
{
    serverMan=inMan;
    tableData=[[NSMutableArray alloc]init];
    [self loadData];
}
-(void)loadData
{
    [tableData removeAllObjects];
    for (int r=0; r<[serverMan getNumServers]; r++)
    {
        [tableData addObject:[[NSDictionary alloc]initWithObjects:[NSArray arrayWithObjects:[[serverMan getServer:r]getName], [[serverMan getServer:r]getIP], nil] forKeys:[NSArray arrayWithObjects:@"name", @"ip", nil]]];
    }
}
- (IBAction)addNewServer:(id)sender
{
    [NSApp beginSheet:self.serverEntryWindow
       modalForWindow:(NSWindow *)self.mainWindow
        modalDelegate:self
       didEndSelector:nil
          contextInfo:nil];
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [serverMan getNumServers];
}
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSDictionary *r = [tableData objectAtIndex:row];
    
    NSString *columnIdentifier = [tableColumn identifier];
    
    return [r objectForKey:columnIdentifier];
}
- (IBAction)closeSheet:(id)sender
{
    [self clearFields];
    [NSApp endSheet:self.serverEntryWindow];
    [self.serverEntryWindow orderOut:sender];
    didSelectRow=NO;
}
- (IBAction)saveSettings:(id)sender
{
    if ([[self.serverNameField stringValue]isEqualToString:@""] || [[self.serverIPField stringValue]isEqualToString:@""] || [[self.userNameField stringValue]isEqualToString:@""] || [[self.passwordField stringValue]isEqualToString:@""] || [[self.serverTypeList titleOfSelectedItem]isEqualToString:@"Select Type..."] || [[self.mountPointField stringValue]isEqualToString:@""])
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Entry Not Valid"];
        [alert setInformativeText:@"Please enter all the necessary fields before saving."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    else if (([[self.serverTypeList titleOfSelectedItem]isEqualToString:@"afp"] || [[self.serverTypeList titleOfSelectedItem]isEqualToString:@"smbfs"]) && [[self.serverIPField stringValue]rangeOfString:@"/"].location == NSNotFound)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Invalid IP/Path"];
        [alert setInformativeText:[NSString stringWithFormat:@"You must specify a path to mount when using %@, for example \"1.2.3.4/share\".", [self.serverTypeList titleOfSelectedItem]]];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    else if ([[self.serverIPField stringValue]rangeOfString:@"://"].location != NSNotFound)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Invalid IP/Path"];
        [alert setInformativeText:@"Do not include a prefix in your IP/Path."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    else if ([[self.serverTypeList titleOfSelectedItem]isEqualToString:@"smbfs"] && [[self.workgroupField stringValue]isEqualToString:@""])
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Invalid SMBFS Configuration"];
        [alert setInformativeText:@"You must include a Workgroup or Domain name to connect to a SMB server."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    else
    {
        BOOL proceed=YES;
        if (![[NSFileManager defaultManager]fileExistsAtPath:[self.mountPointField stringValue]])
        {
            proceed=NO;
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"Mountpoint Doesn't Exist"];
            [alert setInformativeText:@"The mountpoint directory you have specified doesn't exist. Would you like it to be created?"];
            [alert addButtonWithTitle:@"Yes"];
            [alert addButtonWithTitle:@"No"];
            if ([alert runModal]==NSAlertFirstButtonReturn)
            {
                [[NSFileManager defaultManager]createDirectoryAtPath:[self.mountPointField stringValue] withIntermediateDirectories:YES attributes:nil error:nil];
                proceed=YES;
            }
        }
        if (proceed)
        {
            if (didSelectRow)
            {
                [serverMan setServer:clickedRow withName:[self.serverNameField stringValue] ofType:[self.serverTypeList titleOfSelectedItem] withIP:[self.serverIPField stringValue] withPort:[self.portField stringValue] withUsername:[self.userNameField stringValue] withPassword:[self.passwordField stringValue]connectAtLaunch:[self.connectOnLaunchBox state] atMountPoint:[self.mountPointField stringValue]inWorkgroup:[self.workgroupField stringValue]];
            }
            else
            {
                [serverMan addServer:[self.serverNameField stringValue] ofType:[self.serverTypeList titleOfSelectedItem] withIP:[self.serverIPField stringValue] withPort:[self.portField stringValue] withUsername:[self.userNameField stringValue] withPassword:[self.passwordField stringValue]connectAtLaunch:[self.connectOnLaunchBox state] atMountPoint:[self.mountPointField stringValue] inWorkgroup:[self.workgroupField stringValue]];
            }
            [self closeSheet:self];
            [self loadData];
            [self.serverTable reloadData];
        }
    }
}


- (IBAction)removeServer:(id)sender
{
    NSInteger selectedRow=[self.serverTable selectedRow];
    if (selectedRow ==-1)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"No Server Selected"];
        [alert setInformativeText:@"Please select a server in the list before trying to delete it."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    else
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Delete Server"];
        [alert setInformativeText:[NSString stringWithFormat:@"Are you sure you want to delete the server named \"%@\"?", [[serverMan getServer:(int)selectedRow] getName]]];
        [alert addButtonWithTitle:@"Cancel"];
        [alert addButtonWithTitle:@"Yes"];
        if ([alert runModal]==NSAlertSecondButtonReturn)
        {
            [serverMan removeServer:(int)selectedRow];
            [self loadData];
            [self.serverTable reloadData];
        }
    }
}
-(void)clearFields
{
    [self.serverNameField setStringValue:@""];
    [self.serverIPField setStringValue:@""];
    [self.portField setStringValue:@""];
    [self.userNameField setStringValue:@""];
    [self.passwordField setStringValue:@""];
    [self.mountPointField setStringValue:@""];
    [self.workgroupField setStringValue:@""];
    [self.workgroupField setEnabled:NO];
    [self.serverTypeList selectItemAtIndex:0];
    [self.connectOnLaunchBox setState:NSOffState];
}
-(void)didDoubleClickRow
{
    clickedRow=[self.serverTable clickedRow];
    [self openEditingForServerIndex:(int)clickedRow];
}
-(void)openEditingForServerIndex:(int)index
{
    clickedRow=index;
    didSelectRow=YES;
    if (clickedRow >-1)
    {
        [self.serverNameField setStringValue:[[serverMan getServer:(int)clickedRow]getName]];
        [self.serverIPField setStringValue:[[serverMan getServer:(int)clickedRow]getIP]];
        [self.portField setStringValue:[[serverMan getServer:(int)clickedRow]getPort]];
        [self.userNameField setStringValue:[[serverMan getServer:(int)clickedRow]getUsername]];
        [self.passwordField setStringValue:[[serverMan getServer:(int)clickedRow]getPassword]];
        [self.serverTypeList selectItemWithTitle:[[serverMan getServer:(int)clickedRow]getType]];
        [self.connectOnLaunchBox setState:[[NSNumber numberWithBool:[[serverMan getServer:(int)clickedRow]shouldConnectAtLaunch]]integerValue]];
        [self.mountPointField setStringValue:[[serverMan getServer:(int)clickedRow]getMountPoint]];
        [self.workgroupField setStringValue:[[serverMan getServer:(int)clickedRow]getWorkgroup]];
        if ([[[serverMan getServer:(int)clickedRow]getType]isEqualToString:@"smbfs"])
        {
            [self.workgroupField setEnabled:YES];
        }
        else
        {
            [self.workgroupField setEnabled:NO];
        }
        [NSApp beginSheet:self.serverEntryWindow
           modalForWindow:(NSWindow *)self.mainWindow
            modalDelegate:self
           didEndSelector:nil
              contextInfo:nil];
    }
}
@end
