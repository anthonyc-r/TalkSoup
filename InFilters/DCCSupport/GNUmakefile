include $(GNUSTEP_MAKEFILES)/common.make
BUNDLE_NAME = DCCSupport


ifeq ($(USE_APPKIT),)
USE_APPKIT = yes
endif

#BUNDLE_INSTALL_DIR = $(GNUSTEP_APPLICATION_SUPPORT)/TalkSoup/InFilters
$(BUNDLE_NAME)_COPY_INTO_DIR = ../../Source/TalkSoup.app/Resources/InFilters

DCCSupport_OBJC_FILES = DCCTransfer.m DCCSupport.m DCCObject.m DCCSender.m DCCGetter.m

ifeq ($(USE_APPKIT), yes)
DCCSupport_OBJC_FILES += DCCSupportPreferencesController.m
ifeq ($(OBJC_RUNTIME_LIB), apple)
DCCSupport_LOCALIZED_RESOURCE_FILES = DCCSupportPreferences.nib
else
DCCSupport_LOCALIZED_RESOURCE_FILES = DCCSupportPreferences.gorm
endif
else
GUI_LIB =
endif

DCCSupport_LANGUAGES = English
DCCSupport_LOCALIZED_RESOURCE_FILES += Localizable.strings
DCCSupport_RESOURCE_FILES = AllLanguages/Defaults.plist AllLanguages/dccsupport_prefs.tiff

DCCSupport_PRINCIPAL_CLASS = DCCSupport

ifeq ($(OBJC_RUNTIME_LIB), apple)
DCCSupport_BUNDLE_LIBS = -framework netclasses -framework TalkSoupBundles $(ADDITIONAL_FRAMEWORK_DIRS)
else
DCCSupport_BUNDLE_LIBS = -lTalkSoupBundles -lnetclasses
endif

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble
