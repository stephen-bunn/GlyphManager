//
//  AlfredAnalytics.h
//  GlyphManager
//
//  Created by Stephen Bunn on 3/24/14.
//  Copyright (c) 2014 Ritashugisha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface AlfredAnalytics : NSObject
{
    BOOL warningsSuppressed;
    BOOL darkIcons;
    NSString *darkSuffix;
    NSString *lightSuffix;
    NSString *currentPath;
    NSDictionary *alfredPreferences;
    NSDictionary *appearancePreferences;
    NSMutableArray *darkGlyphs;
    NSMutableArray *lightGlyphs;
    NSMutableDictionary *glyphList;
}

-(id) init;
-(void)setSuffixes:(NSString*)light darkArg:(NSString*)dark;
-(void)onOutput:(NSString*)msg;
-(void)suppressWarnings;
-(NSString*)getPrefPath;
-(NSString*)getThemeName;
-(NSDictionary*)getAlfredPreferences;
-(NSDictionary*)getAppearancePreferences;
-(NSDictionary*)getInstalledThemes;
-(NSDictionary*)getCurrentTheme;
-(NSColor*)getBackgroundColor;
-(BOOL)isThemeDark;
-(BOOL)isThemeLight;
-(void)retrieveGlyphs;
-(NSMutableArray*)getCommon:(NSString*)extension;
-(NSMutableArray*)getGlyphs:(NSString*)delimeter;
-(void)reformatGlyphs:(NSString*)delimeter newDeli:(NSString*)newDelimeter;
-(void)checkCommon:(NSMutableArray*)glyphArray searchSuffix:(NSString*)theSuffix;
-(void)checkAlternates:(NSMutableArray*)glyphArray;
-(BOOL)validateChange;
-(void)commitChange;

@end
