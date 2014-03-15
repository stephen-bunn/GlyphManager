//
//  AlfredAnalytics.m
//  GlyphSetup
//
//  Created by Stephen Bunn on 3/13/14.
//  Copyright (c) 2014 Ritashugisha. All rights reserved.
//

#import "AlfredAnalytics.h"

@implementation AlfredAnalytics

// (id)init
// Initialize the AlfredAnalytics object.
-(id)init {
    if (self = [super init]) {
        alfredPreferences = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:[@"~/Library/Preferences/com.runningwithcrayons.Alfred-Preferences.plist" stringByExpandingTildeInPath]] options:NSPropertyListImmutable format:NULL error:NULL];
    }
    return self;
}

// (void)onOutput:(NSString*)msg
// Write a message to stdout.
//
// (NSString*)msg Message to be written
-(void)onOutput:(NSString*)msg {
    [msg writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

// (NSString*)getSyncPath
// Get the path of Alfred Preferences if Alfred is setup for sync paths.
-(NSString*)getSyncPath {
    NSString *syncPath = [alfredPreferences objectForKey:@"syncfolder"];
    if (syncPath == nil) {
        syncPath = @"~/Library/Application Support/Alfred 2/";
    }
    return [syncPath stringByExpandingTildeInPath];
}

// (NSString*)getThemeName
// Get the name of the theme in current use.
-(NSString*)getThemeName {
    NSString *themeName = [alfredPreferences objectForKey:@"appearance.theme"];
    if (themeName == nil) {
        themeName = @"alfred.theme.light";
    }
    return themeName;
}

// (NSDictionary*)getAppearancePreferences
// Set the appearance preferences by reading the appearance plist.
-(NSDictionary*)getAppearancePreferences {
    if (appearancePreferences) {
        return appearancePreferences;
    }
    else {
        appearancePreferences = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:[[self getSyncPath] stringByAppendingString:@"/Alfred.alfredpreferences/preferences/appearance/prefs.plist"]] options:NSPropertyListImmutable format:NULL error:NULL];
    }
    return appearancePreferences;
}

// (NSDictionary*)getInstalledTheme
// Get the user's installed themes.
-(NSDictionary*)getInstalledThemes {
    return [[self getAppearancePreferences] objectForKey:@"themes"];
}

// (NSDictionary*)getCurrentTheme
// Get the name of the user's current theme.
-(NSDictionary*)getCurrentTheme {
    return [[self getInstalledThemes] objectForKey:[self getThemeName]];
}

// (NSColor*)getBackgroundColor
// Get the color of the user's current theme.
-(NSColor*)getBackgroundColor {
    return [[NSUnarchiver unarchiveObjectWithData:[[self getCurrentTheme] objectForKey:@"background"]] colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
}

// (BOOL)isThemeDark
// Check if the theme is dark or not.
-(BOOL)isThemeDark{
    NSString *currentTheme = [self getThemeName];
    if (![currentTheme hasPrefix:@"alfred.theme.custom"] &&
        [currentTheme rangeOfString:@"dark"].location != NSNotFound) {
        return YES;
    } else if (![currentTheme hasPrefix:@"alfred.theme.custom"] || currentTheme == nil) {
        return NO;
    } else {
        return [[self getBackgroundColor] brightnessComponent] < 0.5;
    }
}

// (BOOL)isThemeLight
// Check if the theme is light or not.
-(BOOL)isThemeLight {
    return ![self isThemeDark];
}

// (void)validateChange:(NSString*)light darkArg:(NSString*)dark
// Validate the icon change.
//
// (NSString*)light Light commandline argument
// (NSString*)dark Dark commandline argument
-(void)validateChange:(NSString*)light darkArg:(NSString*)dark {
    glyphIndex = [NSMutableDictionary dictionary];
    darkIcons = false;
    NSString *postFix = dark;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *currentPath = [[[NSFileManager alloc] init] currentDirectoryPath];
    NSDirectoryEnumerator *directoryEnum = [fileManager enumeratorAtPath:currentPath];
    NSString *file = nil;
    NSMutableArray *missingIcons = [[NSMutableArray alloc] init];
    NSMutableArray *darkGlyphs = [[NSMutableArray alloc] init];
    NSMutableArray *lightGlyphs = [[NSMutableArray alloc] init];
    
    while (file = [directoryEnum nextObject]) {
        if ([[[file lastPathComponent] stringByDeletingPathExtension] rangeOfString:light].location != NSNotFound) {
            [lightGlyphs addObject:file];
            darkIcons = true;
        }
        else if ([[[file lastPathComponent] stringByDeletingPathExtension] rangeOfString:dark].location != NSNotFound) {
            [darkGlyphs addObject:file];
        }
        if ([darkGlyphs count] > 0 && [lightGlyphs count] > 0) {
            if ([darkGlyphs count] > [lightGlyphs count]) {
                for (id fileName in lightGlyphs) {
                    [self onOutput:[NSString stringWithFormat:@"Error: malformed icon filename \"%@\"\n", fileName]];
                }
            }
            else {
                for (id fileName in darkGlyphs) {
                    [self onOutput:[NSString stringWithFormat:@"Error: malformed icon filename \"%@\"\n", fileName]];
                }
            }
            [[NSApplication sharedApplication] terminate:nil];
        }
        if ((darkIcons && [[[file lastPathComponent] stringByDeletingPathExtension] rangeOfString:dark].location != NSNotFound) || (!darkIcons && [[[file lastPathComponent] stringByDeletingPathExtension] rangeOfString:dark].location != NSNotFound)) {
            [missingIcons addObject:file];
        }
    }
    if (darkIcons) {
        postFix = light;
    }
    file = nil;
    directoryEnum = [fileManager enumeratorAtPath:currentPath];
    while (file = [directoryEnum nextObject]) {
        if ([[[file lastPathComponent] stringByDeletingPathExtension] hasSuffix:postFix]) {
            [glyphIndex setObject:[currentPath stringByAppendingPathComponent:[file stringByReplacingOccurrencesOfString:postFix withString:@""]] forKey:[currentPath stringByAppendingPathComponent:file]];
        }
    }
    [missingIcons removeAllObjects];
    for (id key in glyphIndex) {
        if (![fileManager fileExistsAtPath:[glyphIndex objectForKey:key]]) {
            [missingIcons addObject:[[glyphIndex objectForKey:key] lastPathComponent]];
        }
    }
    if ([missingIcons count] > 0) {
        for (id iconName in missingIcons) {
            [self onOutput:[NSString stringWithFormat:@"Error: missing icon \"%@\"\n", iconName]];
        }
        [[NSApplication sharedApplication] terminate:nil];
    }
}

// (void)commitChange:(NSString*)light darkArg:(NSString*)dark
// Commit the icon change.
//
// (NSString*)light Light commandline argument
// (NSString*)dark Dark commandline argument
-(void)commitChange:(NSString*)light darkArg:(NSString*)dark {
    NSString *postFix = dark;
    NSString *newFix = light;
    if (darkIcons) {
        postFix = light;
        newFix = dark;
    }
    if ((darkIcons && [self isThemeDark]) || (!darkIcons && [self isThemeLight])) {
        for (id key in glyphIndex) {
            NSString *saveV = [glyphIndex objectForKey:key];
            NSString *newFixFile = [NSString stringWithFormat:@"%@%@.%@", [[[[glyphIndex objectForKey:key] lastPathComponent] stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:postFix withString:@""], newFix, [[[glyphIndex objectForKey:key] lastPathComponent] pathExtension]];
            NSString *newFixPath = [NSString stringWithFormat:@"%@/%@", [[glyphIndex objectForKey:key] stringByDeletingLastPathComponent], newFixFile];
            [[NSFileManager defaultManager] moveItemAtPath:[glyphIndex objectForKey:key] toPath:newFixPath error:NULL];
            [[NSFileManager defaultManager] moveItemAtPath:key toPath:saveV error:NULL];
        }
    }
}

@end
