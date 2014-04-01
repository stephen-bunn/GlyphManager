//
//  AlfredAnalytics.m
//  GlyphManager
//
//  Created by Stephen Bunn on 3/24/14.
//  Copyright (c) 2014 Ritashugisha. All rights reserved.
//

#import "AlfredAnalytics.h"

@implementation AlfredAnalytics

// (id)init
// Initialize the AlfredAnalytics object.
-(id)init
{
    if (self == [super init])
    {
        currentPath = [[[NSFileManager alloc] init] currentDirectoryPath];
        warningsSuppressed = false;
        alfredPreferences = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:[@"~/Library/Preferences/com.runningwithcrayons.Alfred-Preferences.plist" stringByExpandingTildeInPath]] options:NSPropertyListImmutable format:NULL error:NULL];
    }
    return self;
}

-(void)suppressWarnings
{
    if (!warningsSuppressed)
    {
        warningsSuppressed = true;
    }
}

// (void)setSuffixes:(NSString*)light darkArg:(NSString*)dark
// Set the light and dark delimeter suffixes.
//
// (NSString*)light Light suffix
// (NSString*)dark Dark Suffix
-(void)setSuffixes:(NSString*)light darkArg:(NSString*)dark
{
    lightSuffix = light;
    darkSuffix = dark;
}

// (void)onOutput:(NSString*)msg
// Write a message to stdout.
//
// (NSString*)msg Message to be written
-(void)onOutput:(NSString*)msg
{
    [msg writeToFile:@"/dev/stdout" atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

// (NSString*)getSyncPath
// Get the path of Alfred Preferences if Alfred is setup for sync paths.
-(NSString*)getPrefPath
{
    NSString *syncPath = [alfredPreferences objectForKey:@"syncfolder"];
    if (syncPath == nil)
    {
        syncPath = @"~/Library/Application Support/Alfred 2/";
    }
    return [syncPath stringByExpandingTildeInPath];
}

// (NSString*)getThemeName
// Get the name of the theme in current use.
-(NSString*)getThemeName
{
    NSString *themeName = [alfredPreferences objectForKey:@"appearance.theme"];
    if (themeName == nil)
    {
        themeName = @"alfred.theme.light";
    }
    return themeName;
}

// (NSDictionary*)getAlfredPrefernces
// Return the Alfred preferences plist.
-(NSDictionary*)getAlfredPreferences
{
    return alfredPreferences;
}

// (NSDictionary*)getAppearancePreferences
// Set the appearance preferences by reading the appearance plist.
-(NSDictionary*)getAppearancePreferences
    {
    if (appearancePreferences)
    {
        return appearancePreferences;
    }
    else
    {
        appearancePreferences = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:[[self getPrefPath] stringByAppendingString:@"/Alfred.alfredpreferences/preferences/appearance/prefs.plist"]] options:NSPropertyListImmutable format:NULL error:NULL];
    }
    return appearancePreferences;
}

// (NSDictionary*)getInstalledTheme
// Get the user's installed themes.
-(NSDictionary*)getInstalledThemes
{
    return [[self getAppearancePreferences] objectForKey:@"themes"];
}

// (NSDictionary*)getCurrentTheme
// Get the name of the user's current theme.
-(NSDictionary*)getCurrentTheme
{
    return [[self getInstalledThemes] objectForKey:[self getThemeName]];
}

// (NSColor*)getBackgroundColor
// Get the color of the user's current theme.
-(NSColor*)getBackgroundColor
{
    return [[NSUnarchiver unarchiveObjectWithData:[[self getCurrentTheme] objectForKey:@"background"]] colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
}

// (BOOL)isThemeDark
// Check if the theme is dark or not.
-(BOOL)isThemeDark
{
    NSString *currentTheme = [self getThemeName];
    if (![currentTheme hasPrefix:@"alfred.theme.custom"] &&
        [currentTheme rangeOfString:@"dark"].location != NSNotFound)
    {
        return YES;
    }
    else if (![currentTheme hasPrefix:@"alfred.theme.custom"] || currentTheme == nil)
    {
        return NO;
    }
    else
    {
        return [[self getBackgroundColor] brightnessComponent] < 0.5;
    }
}

// (BOOL)isThemeLight
// Check if the theme is light or not.
-(BOOL)isThemeLight
{
    return (![self isThemeDark]);
}

// (void)retrieveGlyphs
// Set global variables for dark and light glyphs.
-(void)retrieveGlyphs
{
    darkGlyphs = [self getGlyphs:darkSuffix];
    lightGlyphs = [self getGlyphs:lightSuffix];
}

// (NSMutableArray*)getCommon:(NSString*)extension
// Get all files of type extension.
//
// (NSString*)extension String of extension to filter by
-(NSMutableArray*)getCommon:(NSString*)extension
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:currentPath];
    NSString *file = nil;
    while (file = [dirEnum nextObject])
    {
        if ([[file pathExtension]isEqualToString:extension])
        {
            [results addObject:[NSString stringWithFormat:@"%@/%@", currentPath, file]];
        }
    }
    return results;
}

// (NSMutableArray*)getGlyphs:(NSString*)delimeter
// Get all files with the delimeter at the end of the file name.
//
// (NSString*)delimeter File suffix to add
-(NSMutableArray*)getGlyphs:(NSString*)delimeter
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:currentPath];
    NSString *file = nil;
    while (file = [dirEnum nextObject])
    {
        if ([[[file lastPathComponent] stringByDeletingPathExtension] rangeOfString:delimeter].location != NSNotFound)
        {
            [results addObject:[NSString stringWithFormat:@"%@/%@", currentPath, file]];
        }
    }
    return results;
}

// (void)reformatGlyphs:(NSString*)delimeter newDeli:(NSString*)newDelimeter
// Rename all glyphs with suffix "delimeter" to suffix "newDelimeter"
//
// (NSString*)delimeter Suffix to search for
// (NSString*)newDelimeter Suffix to change to
-(void)reformatGlyphs:(NSString*)delimeter newDeli:(NSString*)newDelimeter
{
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:currentPath];
    NSString *file = nil;
    while (file = [dirEnum nextObject])
    {
        if ([[[file lastPathComponent] stringByDeletingPathExtension] rangeOfString:delimeter].location != NSNotFound)
        {
            NSString *oldFile = [NSString stringWithFormat:@"%@/%@", currentPath, file];
            NSString *newFile = [NSString stringWithFormat:@"%@/%@/%@.%@", currentPath, [file stringByDeletingLastPathComponent], [[[file lastPathComponent] stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:delimeter withString:@""], [file pathExtension]];
            [self onOutput:[NSString stringWithFormat:@"\033[.1m\033[.31mFixingIcon:\033[.0m %@ -> %@\n", [oldFile lastPathComponent], [newFile lastPathComponent]]];
            [[[NSFileManager alloc] init] moveItemAtPath:oldFile toPath:newFile error:NULL];
        }
    }
}

// (void)checkCommon:(NSMutableArray*)glyphArray searchSuffix:(NSString*)theSuffix
// Check for consistency of alternates.
//
// (NSMutableArray*)glyphArray Array of glyphs
// (NSString*)theSuffix The suffix to search for
-(void)checkCommon:(NSMutableArray*)glyphArray searchSuffix:(NSString*)theSuffix
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL missingAny = false;
    for (id glyphPath in glyphArray)
    {
        NSString *fileAlt = [NSString stringWithFormat:@"%@%@.%@", [glyphPath stringByDeletingPathExtension], theSuffix, [glyphPath pathExtension]];
        if ([[[glyphPath lastPathComponent] stringByDeletingPathExtension] rangeOfString:theSuffix].location == NSNotFound && ![fileManager fileExistsAtPath:fileAlt])
        {
            missingAny = true;
            if (!warningsSuppressed)
            {
                [self onOutput:[NSString stringWithFormat:@"\033[.1m\033[.33mMissingAlternate:\033[.0m %@\n", fileAlt]];
            }
        }
    }
    if (missingAny && !warningsSuppressed)
    {
            [[NSApplication sharedApplication] terminate:nil];
    }
}

// (void)checkAlternates:(NSMutableArray*)glyphArray
// Check for consistency of alternates.
//
// (NSMutableArray*)glyphArray Array of glyphs
-(void)checkAlternates:(NSMutableArray*)glyphArray
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL missingAny = false;
    for (id glyphPath in glyphArray)
    {
        NSString *fileCommon =[NSString stringWithFormat:@"%@/%@.%@", [glyphPath stringByDeletingLastPathComponent], [[[glyphPath lastPathComponent] stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:darkSuffix withString:@""], [glyphPath pathExtension]];
        if (![fileManager fileExistsAtPath:fileCommon])
        {
            missingAny = true;
            [self onOutput:[NSString stringWithFormat:@"\033[.1m\033[.31mMissingCommon:\033[.0m %@\n", fileCommon]];
        }
    }
    if (missingAny)
    {
        [[NSApplication sharedApplication] terminate:nil];
    }

}

// (void)validateChange
// Validate the icon change.
-(BOOL)validateChange
{
    [self retrieveGlyphs];
    NSMutableArray *commonGlyphs = [self getCommon:@"png"];
    glyphList = [NSMutableDictionary dictionary];
    if ([darkGlyphs count] > 0 && [lightGlyphs count] > 0)
    {
        [self onOutput:[NSString stringWithFormat:@"\033[.1m\033[.31mAttemptingIconFix!\033[.0m\n"]];
        if ([darkGlyphs count] > [lightGlyphs count])
        {
            [self reformatGlyphs:lightSuffix newDeli:darkSuffix];
        }
        else
        {
            [self reformatGlyphs:darkSuffix newDeli:lightSuffix];
        }
        [self retrieveGlyphs];
    }
    if ([darkGlyphs count] > 0 && [lightGlyphs count] == 0)
    {
        darkIcons = true;
        [self checkCommon:commonGlyphs searchSuffix:darkSuffix];
        [self checkAlternates:darkGlyphs];
    }
    else
    {
        darkIcons = false;
        [self checkCommon:commonGlyphs searchSuffix:lightSuffix];
        [self checkAlternates:lightGlyphs];
    }
    NSString *postFix = lightSuffix;
    if (darkIcons)
    {
        postFix = darkSuffix;
    }
    NSDirectoryEnumerator *directoryEnum = [[NSFileManager defaultManager] enumeratorAtPath:[[[NSFileManager alloc] init] currentDirectoryPath]];
    NSString *file = nil;
    while (file = [directoryEnum nextObject])
    {
        if ([[[file lastPathComponent] stringByDeletingPathExtension] hasSuffix:postFix])
        {
            [glyphList setObject:[currentPath stringByAppendingPathComponent:[file stringByReplacingOccurrencesOfString:postFix withString:@""]] forKey:[currentPath stringByAppendingPathComponent:file]];
        }
    }
    return YES;
}

// (void)commitChange
// Commit the icon change.
-(void)commitChange
{
    NSString *currentFix = lightSuffix;
    NSString *newFix = darkSuffix;
    if (darkIcons)
    {
        currentFix = darkSuffix;
        newFix = lightSuffix;
    }
    if ((!darkIcons && [self isThemeDark]) || (darkIcons && [self isThemeLight]))
    {
        for (id key in glyphList)
        {
            NSString *saveValue = [glyphList objectForKey:key];
            NSString *newFixFile = [NSString stringWithFormat:@"%@%@.%@", [[[[glyphList objectForKey:key] lastPathComponent] stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:currentFix withString:@""], newFix, [[[glyphList objectForKey:key] lastPathComponent] pathExtension]];
           NSString *newFixPath = [NSString stringWithFormat:@"%@/%@", [[glyphList objectForKey:key] stringByDeletingLastPathComponent], newFixFile];
            [[NSFileManager defaultManager] moveItemAtPath:[glyphList objectForKey:key] toPath:newFixPath error:NULL];
            [[NSFileManager defaultManager] moveItemAtPath:key toPath:saveValue error:NULL];
        }
    }
}

@end
