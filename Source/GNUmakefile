include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = TalkSoup
PACKAGE_NAME = TalkSoup
VERSION = 1.1
TalkSoup_APPLICATION_ICON = TalkSoup.tiff

TalkSoup_OBJC_FILES = main.m commands.m

TalkSoup_RESOURCE_FILES = Defaults.plist Images/TalkSoup.tiff Images/TalkSoup.icns

TalkSoup_GUI_LIBS = -lTalkSoupBundles

ADDITIONAL_LDFLAGS += -v
GUI_LIB =

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/application.make
-include GNUmakefile.postamble

