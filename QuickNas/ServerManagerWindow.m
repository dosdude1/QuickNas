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
    [self.serverTable setAction:@selector(didClickRow)];
    serverTypes = [[NSArray alloc]initWithObjects:@"Select Type...", @"afp", @"smbfs", nil];
    [self.serverTypeList addItemsWithTitles:serverTypes];
    [self.serverTypeList setTarget:self];
    contextualMenu = [[NSMenu alloc]init];
    [contextualMenu setAutoenablesItems:NO];
    [contextualMenu addItemWithTitle:@"Edit..." action:@selector(editServer) keyEquivalent:@""];
    [contextualMenu addItemWithTitle:@"Delete" action:@selector(removeServer:) keyEquivalent:@""];
    [self.serverTable setMenu:contextualMenu];
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
                [serverMan setServer:clickedRow withName:[self.serverNameField stringValue] ofType:[self.serverTypeList titleOfSelectedItem] withIP:[self.serverIPField stringValue] withUsername:[self.userNameField stringValue] withPassword:[self.passwordField stringValue]connectAtLaunch:[self.connectOnLaunchBox state] atMountPoint:[self.mountPointField stringValue]];
            }
            else
            {
                [serverMan addServer:[self.serverNameField stringValue] ofType:[self.serverTypeList titleOfSelectedItem] withIP:[self.serverIPField stringValue] withUsername:[self.userNameField stringValue] withPassword:[self.passwordField stringValue]connectAtLaunch:[self.connectOnLaunchBox state] atMountPoint:[self.mountPointField stringValue]];
            }
            [self closeSheet:self];
            [self loadData];
            [self.serverTable reloadData];
        }
    }
}


- (IBAction)removeServer:(id)sender
{
    clickedRow=[self.serverTable clickedRow];
    if (clickedRow == -1)
    {
        clickedRow=[self.serverTable selectedRow];
    }
    if (clickedRow>-1)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Delete Server"];
        [alert setInformativeText:[NSString stringWithFormat:@"Are you sure you want to delete the server named \"%@\"?", [[serverMan getServer:(int)clickedRow] getName]]];
        [alert addButtonWithTitle:@"Cancel"];
        [alert addButtonWithTitle:@"Yes"];
        if ([alert runModal]==NSAlertSecondButtonReturn)
        {
            [serverMan removeServer:(int)clickedRow];
            [self loadData];
            [self.serverTable reloadData];
        }
    }
}
-(void)clearFields
{
    [self.serverNameField setStringValue:@""];
    [self.serverIPField setStringValue:@""];
    [self.userNameField setStringValue:@""];
    [self.passwordField setStringValue:@""];
    [self.mountPointField setStringValue:@""];
    [self.serverTypeList selectItemAtIndex:0];
    [self.connectOnLaunchBox setState:NSOffState];
}
-(void)didDoubleClickRow
{
    clickedRow=[self.serverTable clickedRow];
    [self openEditingForServerIndex:(int)clickedRow];
}
-(void)editServer
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
        [self.userNameField setStringValue:[[serverMan getServer:(int)clickedRow]getUsername]];
        [self.passwordField setStringValue:[[serverMan getServer:(int)clickedRow]getPassword]];
        [self.serverTypeList selectItemWithTitle:[[serverMan getServer:(int)clickedRow]getType]];
        [self.connectOnLaunchBox setState:[[NSNumber numberWithBool:[[serverMan getServer:(int)clickedRow]shouldConnectAtLaunch]]integerValue]];
        [self.mountPointField setStringValue:[[serverMan getServer:(int)clickedRow]getMountPoint]];
        
        [NSApp beginSheet:self.serverEntryWindow
           modalForWindow:(NSWindow *)self.mainWindow
            modalDelegate:self
           didEndSelector:nil
              contextInfo:nil];
    }
}
-(void)didClickRow
{
    if ([self.serverTable clickedRow] > -1)
    {
        [self.removeServerButton setEnabled:YES];
    }
    else
    {
        [self.removeServerButton setEnabled:NO];
    }
}
- (IBAction)browseForMountpt:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton)
    {
        NSArray* files = [panel URLs];
        [self.mountPointField setStringValue:[[files objectAtIndex:0]path]];
    }
}
@end
