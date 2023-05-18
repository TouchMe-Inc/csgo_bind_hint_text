# About bind_hint_text
Allows you to fix the hint text for a certain time

## How it work?
Add to the top of the plugin:
```pawn
#include <bind_hint_text>
```

After that, the native will become available:
```pawn
native void BindHintText(float fDuration, int iClient, const char[] sFormat, any ...);
```
Now you can use it just like the original PrintHintText():
```pawn
BindHintText(1.0, iClient, "Message for %N", iClient);
```

## Compatible with PrintHintText()?
Each PrintHintText() message is a priority. 
The message from BindHintText() will wait until the PrintHintText() message finishes showing.
