include $(GNUSTEP_MAKEFILES)/common.make
BUNDLE_NAME = KeepAlive

#BUNDLE_INSTALL_DIR = $(GNUSTEP_APPLICATION_SUPPORT)/TalkSoup/InFilters
$(BUNDLE_NAME)_COPY_INTO_DIR = ../../Source/TalkSoup.app/Resources/InFilters

KeepAlive_LANGUAGES = English
KeepAlive_LOCALIZED_RESOURCE_FILES = Localizable.strings

KeepAlive_PRINCIPAL_CLASS = KeepAlive

KeepAlive_OBJC_FILES = KeepAlive.m

ifeq ($(OBJC_RUNTIME_LIB), apple)
KeepAlive_BUNDLE_LIBS = -framework TalkSoupBundles $(ADDITIONAL_FRAMEWORK_DIRS)
else
KeepAlive_BUNDLE_LIBS = -lTalkSoupBundles
endif

GUI_LIB = 

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble

