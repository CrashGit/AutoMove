# AutoMove
Auto walk/sprint in games.

## What is the scope of this script?

The purpose of this script is to make it easier to fine-tune the starting/stopping of automovement in games. When I first wrote a script for automovement, it looked something like this:
```
AutoMove(forward := 'w', sprint := 'LShift')
{
    if not KeyWait(forward, 'T1') and not KeyWait(sprint, 'T1')
        return
    if GetKeyState(forward)
        Send('{w up}{LShift up}')
    else
        Send('{w down}{LShift down}')
}
```

It was simple and did exactly what it was supposed to. However, a side effect of this was that my forward key would be held down in situations where I didn't want it to. For example, if I hit my backwards key, it would continue moving forward when I let go. This meant I had to create additional `~hotkeys::` to send my forward and/or sprint key up which was tedious. This inputhook method allows you to simply pass the keys necessary as an argument (barring mouse keys as inputhook only hooks keyboard keys).


## How it works

Assign the function to a hotkey, preferrably using a #HotIf directive for your specific game.
```
#HotIf WinActive('ahk_exe darktide.exe')
*XButton1::AutoMove()
#HotIf
```

In this example, pressing XButton1 (what is commonly known as Mouse4), will hold down forward. Pressing it again will release forward. If you are holding down your sprint key when you initially press it, it will hold down sprint as well.

If you hold down XButton1 for 0.3 seconds (can be adjusted in the function), it will also hold down sprint automatically in addtion to moving forward.

There's a timeout for how long you can continue holding forward (adjustable and defaults to 1 sec) before it decides you pressed the AutoMove hotkey by accident and won't trigger it. Similar thing for sprint before it decides not to hold down sprint.


## Adding more stop keys

There are two ways to go about this, I suggest using both ways because they are used for different purposes.

By default, AutoMove stops when you press w, s, escape, or left alt. If you look inside the function, there's a variable called `default_keys`. The intention of this particular variable is for keys that feel you will ***always*** want to stop the function.

For keys that are more game-specific, pass the keys as an argument when assigning the function to a hotkey:
```
*XButton1::AutoMove('{Tab}m')
```

In the above example, in addition to the keys in `default_keys`, `Tab` and `m` (commonly used to open inventory and map) also stop automovement.

If you've never used inputhook before, it's important to note that any keys with a left and right variant, you must specify which one (or both) that you want to use. For example, `{Ctrl}` will not work like with other functions that accept keys like Send, but `{LCtrl}` and `{RCtrl}` will.
