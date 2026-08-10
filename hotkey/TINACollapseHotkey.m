#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

static NSString *const BitwigBundleIdentifier = @"com.bitwig.studio";

static EventHotKeyRef registeredHotKey = NULL;
static EventHotKeyID hotKeyIdentifier;
static UInt32 configuredKeyCode = 0;
static UInt32 configuredModifiers = 0;
static NSString *configuredCommandPath = nil;
static NSString *configuredDisplayName = nil;
static id activationObserver = nil;

static BOOL isBitwigBundleIdentifier(NSString *bundleIdentifier)
{
   return bundleIdentifier != nil &&
      [bundleIdentifier isEqualToString:BitwigBundleIdentifier];
}

static BOOL isBitwigFrontmost(void)
{
   NSRunningApplication *frontmostApplication =
      [[NSWorkspace sharedWorkspace] frontmostApplication];
   return isBitwigBundleIdentifier(frontmostApplication.bundleIdentifier);
}

static void launchCollapseCommand(void)
{
   if (!isBitwigFrontmost())
   {
      return;
   }

   NSTask *task = [[NSTask alloc] init];
   task.executableURL = [NSURL fileURLWithPath:configuredCommandPath];
   task.arguments = @[@"collapse", @"all", @"devices"];

   NSFileHandle *nullHandle = [NSFileHandle fileHandleWithNullDevice];
   task.standardOutput = nullHandle;
   task.standardError = nullHandle;

   NSError *error = nil;
   if (![task launchAndReturnError:&error])
   {
      NSLog(@"TINACOLLAPSE could not run %@: %@",
         configuredCommandPath, error.localizedDescription);
   }
}

static OSStatus handleHotKeyEvent(
   EventHandlerCallRef nextHandler,
   EventRef event,
   void *userData)
{
   (void)nextHandler;
   (void)userData;

   EventHotKeyID receivedIdentifier;
   OSStatus status = GetEventParameter(
      event,
      kEventParamDirectObject,
      typeEventHotKeyID,
      NULL,
      sizeof(receivedIdentifier),
      NULL,
      &receivedIdentifier
   );

   if (status == noErr &&
       receivedIdentifier.signature == hotKeyIdentifier.signature &&
       receivedIdentifier.id == hotKeyIdentifier.id)
   {
      launchCollapseCommand();
   }

   return noErr;
}

static OSStatus registerConfiguredHotKey(void)
{
   if (registeredHotKey != NULL)
   {
      return noErr;
   }

   return RegisterEventHotKey(
      configuredKeyCode,
      configuredModifiers,
      hotKeyIdentifier,
      GetEventDispatcherTarget(),
      kEventHotKeyExclusive,
      &registeredHotKey
   );
}

static void unregisterConfiguredHotKey(void)
{
   if (registeredHotKey != NULL)
   {
      UnregisterEventHotKey(registeredHotKey);
      registeredHotKey = NULL;
   }
}

static OSStatus updateRegistrationForBundleIdentifier(NSString *bundleIdentifier)
{
   if (isBitwigBundleIdentifier(bundleIdentifier))
   {
      OSStatus status = registerConfiguredHotKey();
      if (status != noErr)
      {
         NSLog(@"TINACOLLAPSE could not register %@ (OSStatus %d)",
            configuredDisplayName, (int)status);
      }
      return status;
   }

   unregisterConfiguredHotKey();
   return noErr;
}

static void updateRegistrationForFrontmostApplication(void)
{
   NSRunningApplication *frontmostApplication =
      [[NSWorkspace sharedWorkspace] frontmostApplication];
   updateRegistrationForBundleIdentifier(frontmostApplication.bundleIdentifier);
}

static BOOL loadConfiguration(NSString *path, NSError **error)
{
   NSDictionary *configuration =
      [NSDictionary dictionaryWithContentsOfFile:path];

   NSNumber *keyCode = configuration[@"keyCode"];
   NSNumber *modifiers = configuration[@"modifiers"];
   NSString *commandPath = configuration[@"commandPath"];
   NSString *displayName = configuration[@"display"];

   if (keyCode == nil || modifiers == nil ||
       commandPath.length == 0 || displayName.length == 0)
   {
      if (error != NULL)
      {
         *error = [NSError errorWithDomain:@"fun.sillytina.TINACOLLAPSE"
            code:1
            userInfo:@{NSLocalizedDescriptionKey:
               @"The hotkey configuration is incomplete."}];
      }
      return NO;
   }

   if (![[NSFileManager defaultManager] isExecutableFileAtPath:commandPath])
   {
      if (error != NULL)
      {
         NSString *description = [NSString stringWithFormat:
            @"The bitwig command is not executable: %@", commandPath];
         *error = [NSError errorWithDomain:@"fun.sillytina.TINACOLLAPSE"
            code:2
            userInfo:@{NSLocalizedDescriptionKey:description}];
      }
      return NO;
   }

   configuredKeyCode = keyCode.unsignedIntValue;
   configuredModifiers = modifiers.unsignedIntValue;
   configuredCommandPath = [commandPath copy];
   configuredDisplayName = [displayName copy];
   return YES;
}

static int validateConfiguration(NSString *path)
{
   NSError *error = nil;
   if (!loadConfiguration(path, &error))
   {
      fprintf(stderr, "%s\n", error.localizedDescription.UTF8String);
      return 2;
   }

   OSStatus status = registerConfiguredHotKey();
   if (status != noErr)
   {
      fprintf(stderr,
         "Could not register %s (OSStatus %d). Choose another shortcut.\n",
         configuredDisplayName.UTF8String,
         (int)status);
      return 3;
   }

   unregisterConfiguredHotKey();
   printf("Validated: %s\n", configuredDisplayName.UTF8String);
   return 0;
}

static int runSelfTest(void)
{
   BOOL passed =
      isBitwigBundleIdentifier(@"com.bitwig.studio") &&
      !isBitwigBundleIdentifier(@"com.apple.Terminal") &&
      !isBitwigBundleIdentifier(nil);

   if (!passed)
   {
      fprintf(stderr, "TINACOLLAPSE bundle gate self-test failed.\n");
      return 1;
   }

   printf("TINACOLLAPSE bundle gate self-test passed.\n");
   return 0;
}

static int runGateTransitionTest(NSString *path)
{
   NSError *error = nil;
   if (!loadConfiguration(path, &error))
   {
      fprintf(stderr, "%s\n", error.localizedDescription.UTF8String);
      return 2;
   }

   updateRegistrationForBundleIdentifier(@"com.apple.Terminal");
   if (registeredHotKey != NULL)
   {
      fprintf(stderr, "The hotkey remained registered outside Bitwig.\n");
      return 4;
   }

   OSStatus status =
      updateRegistrationForBundleIdentifier(@"com.bitwig.studio");
   if (status != noErr || registeredHotKey == NULL)
   {
      fprintf(stderr,
         "The hotkey did not register for Bitwig (OSStatus %d).\n",
         (int)status);
      return 5;
   }

   updateRegistrationForBundleIdentifier(@"com.apple.Terminal");
   if (registeredHotKey != NULL)
   {
      fprintf(stderr, "The hotkey did not release after leaving Bitwig.\n");
      return 6;
   }

   printf("TINACOLLAPSE app gate transition test passed.\n");
   return 0;
}

static void showUsage(void)
{
   fprintf(stderr,
      "Usage: tinacollapse-hotkey --config PATH | --validate PATH | "
      "--gate-test PATH | --self-test\n");
}

int main(int argc, const char *argv[])
{
   @autoreleasepool
   {
      hotKeyIdentifier.signature =
         ((UInt32)'T' << 24) | ((UInt32)'I' << 16) |
         ((UInt32)'N' << 8) | (UInt32)'A';
      hotKeyIdentifier.id = 1;

      if (argc == 2 && strcmp(argv[1], "--self-test") == 0)
      {
         return runSelfTest();
      }

      if (argc != 3)
      {
         showUsage();
         return 64;
      }

      NSString *mode = [NSString stringWithUTF8String:argv[1]];
      NSString *configurationPath = [NSString stringWithUTF8String:argv[2]];

      [NSApplication sharedApplication];
      [NSApp setActivationPolicy:NSApplicationActivationPolicyProhibited];

      if ([mode isEqualToString:@"--validate"])
      {
         return validateConfiguration(configurationPath);
      }

      if ([mode isEqualToString:@"--gate-test"])
      {
         return runGateTransitionTest(configurationPath);
      }

      if (![mode isEqualToString:@"--config"])
      {
         showUsage();
         return 64;
      }

      NSError *error = nil;
      if (!loadConfiguration(configurationPath, &error))
      {
         fprintf(stderr, "%s\n", error.localizedDescription.UTF8String);
         return 2;
      }

      EventTypeSpec eventType = {
         .eventClass = kEventClassKeyboard,
         .eventKind = kEventHotKeyPressed
      };
      InstallEventHandler(
         GetEventDispatcherTarget(),
         NewEventHandlerUPP(handleHotKeyEvent),
         1,
         &eventType,
         NULL,
         NULL
      );

      activationObserver = [[[NSWorkspace sharedWorkspace] notificationCenter]
         addObserverForName:NSWorkspaceDidActivateApplicationNotification
         object:nil
         queue:[NSOperationQueue mainQueue]
         usingBlock:^(NSNotification *notification) {
            (void)notification;
            updateRegistrationForFrontmostApplication();
         }];

      updateRegistrationForFrontmostApplication();
      [NSApp run];

      unregisterConfiguredHotKey();
      if (activationObserver != nil)
      {
         [[[NSWorkspace sharedWorkspace] notificationCenter]
            removeObserver:activationObserver];
      }
   }

   return 0;
}
