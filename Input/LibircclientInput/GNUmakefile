include $(GNUSTEP_MAKEFILES)/common.make
BUNDLE_NAME = LibircclientInput

# BUNDLE_INSTALL_DIR = $(GNUSTEP_APPLICATION_SUPPORT)/TalkSoup/Input

$(BUNDLE_NAME)_COPY_INTO_DIR = ../../Source/TalkSoup.app/Resources/Input

ifeq ($(OBJC_RUNTIME_LIB), apple)
LibircclientInput_BUNDLE_LIBS = -framework ircclient -framework TalkSoupBundles $(ADDITIONAL_FRAMEWORK_DIRS)
else
LibircclientInput_BUNDLE_LIBS = -lTalkSoupBundles -lcrypto -lssl -lircclient
endif

LibircclientInput_PRINCIPAL_CLASS = LibircclientInput

LibircclientInput_OBJC_FILES = main.m Recievers.m

GUI_LIB = 

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/bundle.make
-include GNUmakefile.postamble

