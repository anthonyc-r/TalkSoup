include $(GNUSTEP_MAKEFILES)/common.make
BUNDLE_NAME = Colorizer

#BUNDLE_INSTALL_DIR = $(GNUSTEP_APPLICATION_SUPPORT)/TalkSoup/OutFilters
$(BUNDLE_NAME)_COPY_INTO_DIR = ../../Source/TalkSoup.app/Resources/OutFilters

Colorizer_LANGUAGES = English
Colorizer_LOCALIZED_RESOURCE_FILES = Localizable.strings

Colorizer_PRINCIPAL_CLASS = Colorizer

Colorizer_OBJC_FILES = Colorizer.m

ifeq ($(OBJC_RUNTIME_LIB), apple)
Colorizer_BUNDLE_LIBS = -framework TalkSoupBundles $(ADDITIONAL_FRAMEWORK_DIRS)
else
Colorizer_BUNDLE_LIBS = -lTalkSoupBundles
endif

GUI_LIB = 

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble

