#GlyphManager<sub>(v1.2a)</sub>
--
###Alfred App workflow glyph utility

_This utility exchanges dark and light icons according to the current theme in use._

######Usage
`usage: GlyphManager: [-h] [-dark DARK] [-light LIGHT]`
	
    (C) 2014 Ritashugisha. GlyphManager
    Alfred App workflow glyph utility.
    Exchanges dark and light icons according to the current theme in use.
    
    Arguments:
	    -light		[light icon suffix]
	    -dark		[dark icon suffix]
	    --suppress	[suppress warnings]
    
    Other Arguments:
	    --get-prefpath
	    --get-themes
	    --get-currenttheme
	    --get-themename
	    --get-alfredprefs
	    --get-appearanceprefs
	    --get-themecolor
    
    Example: ./GlyphManager -light -light -dark -dark

IMPORTANT:
	The dark and light suffixes used for your icons will be constant
(https://github.com/Ritashugisha/GlyphManager/blob/master/README.md)

>When GlyphManager is run it will first determine if the current theme in Alfred is dark or light. If the theme is dark, GlyphManager will look for icons within the current directory and any subdirectories with the `-light` tag. If GlyphManager decides to exchange your icons, it will take all icons with no tag and change them to have the `-dark` tag. It will finally take all icons with the `-light` tag and set them as the icons with no tag. This allows easy exchange to and from dark and light icons within workflows.

######PACKAGE DETAILS
Author | Contact | Package | Version
:---: | :---: | :---: | :---:
Ritashugisha | ritashugisha@gmail.com | co.nf.ritashugisha.__GlyphManager__ | v1.2a

######License

__OmniTube__ is currently licensed under the [GNU GPLv3 Free Software License](http://www.gnu.org/licenses/gpl-3.0.html).

![GNU GPLv3](http://gplv3.fsf.org/gplv3-88x31.png "GNU GPLv3")

######CREDITS
>Clinton Strong _(provided the base class)_

--
&copy; 2014 Ritashugisha. 

[![Facebook](http://files.softicons.com/download/social-media-icons/clean-simple-social-icons-by-creative-nerds/png/32x32/Facebook.png "Facebook")](https://www.facebook.com/stephen.bunn.73)	[![Twitter](http://png-3.findicons.com/files/icons/2573/new_social_media_icons_set/32/twitter.png "Twitter")](https://twitter.com/ritashugisha)	[![Github](http://gamebuilderstudio.com/img/design/github-icon.png "GitHub")](https://github.com/Ritashugisha)	[![MailTo](http://i1293.photobucket.com/albums/b599/Ritashugisha/new_zps0e48276f.png "MailTo")](ritashugisha@gmail.com)	[![AlfredApp Profile](http://i1293.photobucket.com/albums/b599/Ritashugisha/UntitledNew_zpsfb3ea780.png "AlfredApp Profile")](http://www.alfredforum.com/user/5520-ritashugisha/)	[![Packal Profile](http://i1293.photobucket.com/albums/b599/Ritashugisha/UntitledNew_zpsc2cb05a9.png "Packal Profile")](http://www.packal.org/users/ritashugisha)	[![Personal Website](http://i1293.photobucket.com/albums/b599/Ritashugisha/UntitledNew_zps88305ee4.gif "Personal Website")](http://www.ritashugisha.co.nf/)
