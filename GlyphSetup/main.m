//
//  main.m
//  GlyphSetup
//
//  Created by Stephen Bunn on 3/13/14.
//  Copyright (c) 2014 Ritashugisha. All rights reserved.
//
//  Thanks to "Clinton Strong" for the base class.
//

#import <Foundation/Foundation.h>
#include "AlfredAnalytics.h"

int main(int argc, const char * argv[]) {
    NSString *usage = @"usage: GlyphSetup: [-h] [-dark DARK] [-light LIGHT]\n";
    NSString *help = @"\u00A9 2014 Ritashugisha. GlyphSetup\nAlfred App workflow glyph utility.\nExchanges dark and light icons according to the current theme in use.\n\nArguments:\n\t-light [light icon suffix]\n\t-dark [dark icon suffix]\n\nExample: ./GlyphSetup -light -light -dark -dark\n\nIMPORTANT:\n\tThe dark and light suffixes used for your icons will be constant\n(https://github.com/Ritashugisha/GlyphSetup/blob/master/README.md)\n";
    NSString *darkPostfix;
    NSString *lightPostfix;
    @autoreleasepool {
        NSArray *commandLine = [[NSProcessInfo processInfo] arguments];
        AlfredAnalytics *object = [[AlfredAnalytics alloc] init];
        if ([commandLine containsObject:@"-h"] || [commandLine containsObject:@"--help"]) {
            [object onOutput:help];
            [[NSApplication sharedApplication] terminate:nil];
        }
        if ([commandLine containsObject:@"--get-prefpath"]) {
            [object onOutput:[NSString stringWithFormat:@"%@\n", [object getSyncPath]]];
            [[NSApplication sharedApplication] terminate:nil];
        }
        if ([commandLine containsObject:@"--get-themename"]) {
            [object onOutput:[NSString stringWithFormat:@"%@\n", [object getThemeName]]];
            [[NSApplication sharedApplication] terminate:nil];
        }
        if ([commandLine containsObject:@"--get-themecolor"]) {
            NSString *stringColor = @"theme.light\n";
            if ([object isThemeDark]) {
                stringColor = @"theme.dark\n";
            }
            [object onOutput:stringColor];
            [[NSApplication sharedApplication] terminate:nil];
        }
        if ([commandLine containsObject:@"--get-theme"]) {
            [object onOutput:[NSString stringWithFormat:@"%@\n", [object getCurrentTheme]]];
            [[NSApplication sharedApplication] terminate:nil];
        }
        if ([commandLine containsObject:@"-dark"] && [commandLine containsObject:@"-light"] && (([commandLine indexOfObject:@"-dark"] - [commandLine indexOfObject:@"-light"] == 2) || ([commandLine indexOfObject:@"-light"] - [commandLine indexOfObject:@"-dark"] == 2)) && [commandLine count] > 4) {
            darkPostfix = commandLine[[commandLine indexOfObject:@"-dark"] + 1];
            lightPostfix = commandLine[[commandLine indexOfObject:@"-light"] + 1];
            [object validateChange:lightPostfix darkArg:darkPostfix];
            [object commitChange:lightPostfix darkArg:darkPostfix];
        }
        else {
            [object onOutput:usage];
        }
        [[NSApplication sharedApplication] terminate:nil];
    }
    return 0;
}

