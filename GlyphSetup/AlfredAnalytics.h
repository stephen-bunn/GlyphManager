//
//  AlfredAnalytics.h
//  GlyphSetup
//
//  Created by Stephen Bunn on 3/13/14.
//  Copyright (c) 2014 Ritashugisha. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AlfredAnalytics : NSObject {
    NSDictionary *alfredPreferences;
    NSDictionary *appearancePreferences;
    NSMutableDictionary *glyphIndex;
    BOOL darkIcons;
}

-(id)init;
-(void)onOutput:(NSString*)msg;
-(NSString*)getSyncPath;
-(NSString*)getThemeName;
-(NSDictionary*)getAppearancePreferences;
-(NSDictionary*)getInstalledThemes;
-(NSDictionary*)getCurrentTheme;
-(NSColor*)getBackgroundColor;
-(BOOL)isThemeDark;
-(BOOL)isThemeLight;
-(void)validateChange:(NSString*)light darkArg:(NSString*)dark;
-(void)commitChange:(NSString*)light darkArg:(NSString*)dark;

@end
