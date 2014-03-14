//
//  AlfredAnalytics.m
//  GlyphSetup
//
//  Created by Stephen Bunn on 3/13/14.
//  Copyright (c) 2014 Ritashugisha. All rights reserved.
//

#import "AlfredAnalytics.h"

@implementation AlfredAnalytics

-(id)init {
    if (self = [super init]) {
        alfredPreferences = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:[@"~/Library/Preferences/com.runningwithcrayons.Alfred-Preferences.plist" stringByExpandingTildeInPath]] options:NSPropertyListImmutable format:NULL error:NULL];
    }
    return self;
}

-(void)onOutput:(NSString*)msg {
    [msg writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

-(NSString*)getSyncPath {
    NSString *syncPath = [alfredPreferences objectForKey:@"syncfolder"];
    if (syncPath == nil) {
        syncPath = @"~/Library/Application Support/Alfred 2/";
    }
    return [syncPath stringByExpandingTildeInPath];
}

-(NSString*)getThemeName {
    NSString *themeName = [alfredPreferences objectForKey:@"appearance.theme"];
    if (themeName == nil) {
        themeName = @"alfred.theme.light";
    }
    return themeName;
}

-(NSDictionary*)getAppearancePreferences {
    if (appearancePreferences) {
        return appearancePreferences;
    }
    else {
        appearancePreferences = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:[[self getSyncPath] stringByAppendingString:@"/Alfred.alfredpreferences/preferences/appearance/prefs.plist"]] options:NSPropertyListImmutable format:NULL error:NULL];
    }
    return appearancePreferences;
}

-(NSDictionary*)getInstalledThemes {
    return [[self getAppearancePreferences] objectForKey:@"themes"];
}

-(NSDictionary*)getCurrentTheme {
    return [[self getInstalledThemes] objectForKey:[self getThemeName]];
}

-(NSColor*)getBackgroundColor {
    return [[NSUnarchiver unarchiveObjectWithData:[[self getCurrentTheme] objectForKey:@"background"]] colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
}

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

-(BOOL)isThemeLight {
    return ![self isThemeDark];
}

-(void)validateChange:(NSString*)light darkArg:(NSString*)dark {
    glyphIndex = [NSMutableDictionary dictionary];
    NSString *postFix = dark;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *currentPath = [[[NSFileManager alloc] init] currentDirectoryPath];
    NSDirectoryEnumerator *directoryEnum = [fileManager enumeratorAtPath:currentPath];
    NSString *file = nil;
    
    while (file = [directoryEnum nextObject]) {
        if ([file rangeOfString:[NSString stringWithFormat:@"%@.png", light]].location != NSNotFound) {
            darkIcons = true;
        }
        if (([file rangeOfString:[NSString stringWithFormat:@"%@.png", dark]].location != NSNotFound) && darkIcons) {
            [self onOutput:[NSString stringWithFormat:@"Error: malformed icon fileaname \"%@\"", file]];
            [[NSApplication sharedApplication] terminate:nil];
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
    NSMutableArray *missingIcons = [[NSMutableArray alloc] init];
    for (id key in glyphIndex) {
        if (![fileManager fileExistsAtPath:[glyphIndex objectForKey:key]]) {
            [missingIcons addObject:[glyphIndex objectForKey:key]];
        }
    }
    if ([missingIcons count] > 0) {
        [self onOutput:@"Error: missing glyphs..."];
        for (id i in missingIcons) {
            [self onOutput:i];
        }
        [[NSApplication sharedApplication] terminate:nil];
    }
}

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
