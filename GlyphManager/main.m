//
//  main.m
//  GlyphManager
//
//  Created by Stephen Bunn on 3/24/14.
//  Copyright (c) 2014 Ritashugisha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlfredAnalytics.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        NSString *version = @"1.2";
        NSString *usage = @"usage: GlyphManager: [-h] [-dark DARK] [-light LIGHT]\n";
        NSString *help = @"\u00A9 2014 Ritashugisha. GlyphManager\nAlfred App workflow glyph utility.\nExchanges dark and light icons according to the current theme in use.\n\nArguments:\n\t-light\t\t[light icon suffix]\n\t-dark\t\t[dark icon suffix]\n\t--suppress\t[suppress warnings]\n\nOther Arguments:\n\t--get-prefpath\n\t--get-themes\n\t--get-currenttheme\n\t--get-themename\n\t--get-alfredprefs\n\t--get-appearanceprefs\n\t--get-themecolor\n\nExample: ./GlyphManager -light -light -dark -dark\n\nIMPORTANT:\n\tThe dark and light suffixes used for your icons will be constant\n(https://github.com/Ritashugisha/GlyphManager/blob/master/README.md)\n";
        NSArray *commandLine = [[NSProcessInfo processInfo] arguments];
        AlfredAnalytics *object = [[AlfredAnalytics alloc] init];
        if ([commandLine containsObject:@"-h"] || [commandLine containsObject:@"--help"])
        {
            [object onOutput:help];
        }
        else if ([commandLine containsObject:@"--version"])
        {
            [object onOutput:[NSString stringWithFormat:@"%@\n", version]];
        }
        else if ([commandLine containsObject:@"--get-prefpath"])
        {
            [object onOutput:[NSString stringWithFormat:@"%@\n", [object getPrefPath]]];
        }
        else if ([commandLine containsObject:@"--get-themes"])
        {
            [object onOutput:[NSString stringWithFormat:@"%@\n", [object getInstalledThemes]]];
        }
        else if ([commandLine containsObject:@"--get-currenttheme"])
        {
            [object onOutput:[NSString stringWithFormat:@"%@\n", [object getCurrentTheme]]];
        }
        else if ([commandLine containsObject:@"--get-themename"])
        {
            [object onOutput:[NSString stringWithFormat:@"%@\n", [object getThemeName]]];
        }
        else if ([commandLine containsObject:@"--get-alfredprefs"])
        {
            [object onOutput:[NSString stringWithFormat:@"%@\n", [object getAlfredPreferences]]];
        }
        else if ([commandLine containsObject:@"--get-appearanceprefs"])
        {
            [object onOutput:[NSString stringWithFormat:@"%@\n", [object getAppearancePreferences]]];
        }
        else if ([commandLine containsObject:@"--get-themecolor"])
        {
            NSString *themeColor = @"theme.light";
            if ([object isThemeDark])
            {
                themeColor = @"theme.dark";
            }
            [object onOutput:[NSString stringWithFormat:@"%@\n", themeColor]];
        }
        else if ([commandLine containsObject:@"-dark"] && [commandLine containsObject:@"-light"] && (([commandLine indexOfObject:@"-dark"] - [commandLine indexOfObject:@"-light"] == 2) || ([commandLine indexOfObject:@"-light"] - [commandLine indexOfObject:@"-dark"] == 2)) && [commandLine count] > 4)
        {
            [object setSuffixes:commandLine[[commandLine indexOfObject:@"-light"] + 1] darkArg:commandLine[[commandLine indexOfObject:@"-dark"] + 1]];
            if ([commandLine containsObject:@"--suppress"])
            {
                [object suppressWarnings];
            }
            if ([object validateChange])
            {
                [object commitChange];
            }
        }
        else
        {
            [object onOutput:usage];
        }
        [[NSApplication sharedApplication] terminate:nil];
    }
    return 0;
}

