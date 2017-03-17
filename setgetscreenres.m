/*
* COMPILE:
*    c++ setgetscreenres.m -framework ApplicationServices -o setgetscreenres
* USE:
*    setgetscreenres 1440 900
*
* Original source: http://hints.macworld.com/article.php?story=20090413120929454
*
* Modifications to disable compiler warnings and list supported resolutions
*/

#include <ApplicationServices/ApplicationServices.h>

bool MyDisplaySwitchToMode (CGDirectDisplayID display, CGDisplayModeRef mode);

int main (int argc, const char * argv[])
{
  int h;                          // horizontal resolution
  int v;                          // vertical resolution
  CGDisplayModeRef switchMode = NULL;     // mode to switch to
  CGDirectDisplayID mainDisplay;  // ID of main display

  CFDictionaryRef CGDisplayCurrentMode(CGDirectDisplayID display);
  if (argc != 3 || !(h = atoi(argv[1])) || !(v = atoi(argv[2])) ) {
    printf("To change resolution: %s <horizontal pixels> <vertical pixels>\n", argv[0]);
  }
  CGRect screenFrame = CGDisplayBounds(kCGDirectMainDisplay);
  CGSize screenSize  = screenFrame.size;
  printf("Current resolution: %4.0f %4.0f\n", screenSize.width, screenSize.height);
  printf("\n");

  // get all modes, iterate through them and select if it matches cmdline parameters
  CFArrayRef allDisplayModes = CGDisplayCopyAllDisplayModes(kCGDirectMainDisplay, NULL);
  printf("Resolutions supported by the display:\n");
  for (int i = 0; i < CFArrayGetCount(allDisplayModes) ; i++) {
    CGDisplayModeRef curMode = (CGDisplayModeRef)CFArrayGetValueAtIndex(allDisplayModes, i);
    int ht = CGDisplayModeGetHeight(curMode);
    int wt = CGDisplayModeGetWidth(curMode);
    char *selected = " ";
    if(ht == v && wt == h) {
      switchMode = curMode;
      selected = "*";
    }
    printf("[%s] %4d %4d\n", selected, wt, ht);
  }

  mainDisplay = CGMainDisplayID();
  if (switchMode) {
    if (!MyDisplaySwitchToMode(mainDisplay, switchMode)) {
      fprintf(stderr, "Error changing resolution to %d %d\n", h, v);
      return 1;
    }
  } else {
    printf("No mode to switch found.\n");
  }

  return 0;
}

bool MyDisplaySwitchToMode (CGDirectDisplayID display, CGDisplayModeRef mode)
{
  CGDisplayConfigRef config;
  if (CGBeginDisplayConfiguration(&config) == kCGErrorSuccess) {
    CGConfigureDisplayWithDisplayMode(config, display, mode, NULL);
    CGCompleteDisplayConfiguration(config, kCGConfigureForSession );
    return true;
  }
  return false;
}
