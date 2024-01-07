#Requires AutoHotkey v2.0
#SingleInstance



; This function isn't necessary for the script, but is useful for games in general.
; Prevents possible issues that can be caused by AHK releasing and pressing modifiers again
; For example, setting up q to be quick swap(swap weapons 1 and 2) in Deep Rock Galactic can cause
; the double-tap sprint to dash ability to trigger without {Blind}, when sprinting and double-tapping q
GameSend(keys) => SendEvent('{Blind}' keys)



/**
 * @param {string} @default_keys    string of all keys to end AutoMove (modifiers must specify Left or Right version)
 * @param {string} @forward         key that moves forward
 * @param {string} @sprint          key for sprinting
 * This version allows you to pass a list of keys to stop movement
 * instead of relying on setting up another #HotIf or other hotkeys
 * that rely on always sending other keys up (e.g. ~s::Send('{w up}) / ~Tab::Send('{w up}{LShift up}') etc.)
 */
AutoMove(deactivate_keys := '', forward := 'w', sprint := 'LShift')
{
    ; useful when there are certain keys you always want to stop the inputhook
    static ih := InputHook('V'),                                        ; initialize InputHook
        default_keys := 'ws{Esc}{LAlt}'                                 ; default keys to always end AutoMove inputhook
    sprinting := GetKeyState(sprint, 'P')                               ; check if holding sprint key when pressed
    ThisHotkey := Key()

    switch ih.InProgress
    {
        case true:                                                      ; if in progress
            if sprinting {                                              ; if sprinting
                ih.Stop()                                               ; stop AutoMove
                SetTimer(SetupInputHook, -1)                            ; start AutoMove again
            } else {                                                    ; if not sprinting
                ih.Stop()                                               ; stop AutoMove
                if sprinting := !KeyWait(ThisHotkey, 'T0.3')            ; check if holding AutoMove hotkey to trigger sprint without need to hold sprint key
                    SetTimer(SetupInputHook, -1)                        ; restart input gathering
                else                                                    ; if not sprinting
                    ResetKeys()                                         ; reset keys held down
            }

        case false:                                                     ; if not in progress
            SetTimer(SetupInputHook, -1)                                ; start AutoMove
    }

    KeyWait(ThisHotkey)                                                 ; prevent extra key repeats

    SetupInputHook()
    {
        if not KeyWait(forward, 'T1')                                   ; if forward isn't released in 1 second
            return                                                      ; return to avoid accidental holdings

        GameSend('{' forward ' down}')                                  ; hold down forward when w is physically released

        if not sprinting                                                ; if sprint wasn't held
            sprinting := !KeyWait(ThisHotkey, 'T0.3')                   ; check if holding AutoMove hotkey to trigger sprint without need to hold sprint key

        if sprinting                                                    ; if sprinting
            if KeyWait(sprint, 'T0.5')                                  ; and sprint key is released within 0.5 seconds (if held)
                GameSend('{' sprint ' down}')                           ; hold down sprint

        ih.KeyOpt(default_keys deactivate_keys, 'E')                    ; keys list ends AutoMove
        ih.OnEnd := (*) => (ih.EndReason = 'EndKey') ? ResetKeys() : 0  ; on end, if endreason is an endkey was used, reset keys
        ih.Start()                                                      ; start collecting input
    }


    ResetKeys() {
        (!GetKeyState(forward, 'P')) ? GameSend('{' forward ' up}') : 0 ; if forward is not pressed, release forward
        (!GetKeyState(sprint,  'P')) ? GameSend('{' sprint  ' up}') : 0 ; if forward is not pressed, release forward
    }

    ; strips hotkey of modifiers
    Key(ThisHotkey := A_ThisHotkey) => RegExReplace(ThisHotkey, '[~*$!^+#<>]')
}
