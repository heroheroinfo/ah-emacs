﻿;;;
;;; Emacs key bind script for AutoHotKey
;;; LastUpdate: 2019/02/11
;;;

;--------------------------------------------------------------------;
; Initial Settings
;--------------------------------------------------------------------;
#NoEnv
#SingleInstance force
#InstallKeybdHook
#UseHook On
#MaxThreadsPerHotkey 5

gEmacsShift := False
gEmacsTwoStroke := False

;; MuHenkan -> Ctrl
vk1D::Ctrl

;--------------------------------------------------------------------;
; Application Specific Settings
;--------------------------------------------------------------------;
;; without hotkey
GroupAdd IgnoreList, ahk_class PuTTY

; Outlook
#IfWinActive ahk_class rctrl_renwnd32
^s::EmacsSend("{F3}")                   ;search mail

;--------------------------------------------------------------------;
; Common Settings
;--------------------------------------------------------------------;
;; Right Alt + Enter -> Left Mouse Click
RAlt & Enter::MouseClick, Left          ;left button click

;; Emacs hotkey
#IfWinNotActive ahk_group IgnoreList
RAlt::EmacsSend("{LWin}")               ;windows key
<+Space::EmacsSend("!{sc029}")          ;toggle ime
^Space::gEmacsShift := !gEmacsShift     ;toggle region
^a::EmacsSend("{Home}", gEmacsShift)    ;beginning of line
^b::EmacsSend("{Left}", gEmacsShift)    ;backward char
^d::EmacsSend("{Del}")                  ;delete char
^e::EmacsSend("{End}", gEmacsShift)     ;end of line
^f::EmacsSend("{Right}", gEmacsShift)   ;forward char
^g::EmacsSend("{Esc}")                  ;quit, cancel 
^h::EmacsSend("{BS}")                   ;delete backward char
^i::EmacsSend("{Tab}")                  ;indent for tab
^j::EmacsSend("{Enter}{Tab}")           ;new line and indent
^k::EmacsSend("+{END}^x")               ;kill line
^m::EmacsSend("{Enter]")                ;new line
^n::EmacsSend("{Down}", gEmacsShift)    ;next line
^o::EmacsSend("{END}{Enter}{Up}")       ;open line
^p::EmacsSend("{Up}", gEmacsShift)      ;previous line
^s::EmacsSend("^f")                     ;isearch forward
^t::EmacsSend("^w")                     ;crose tab
^v::EmacsSend("{PgDn}", gEmacsShift)    ;scroll down
!v::EmacsSend("{PgUp}", gEmacsShift)    ;scroll up
^w::EmacsSend("^x")                     ;kill region
!w::EmacsSend("^c")                     ;kill ring save
^x::EmacsCtrlX()                        ;2 stroke commands with 'x'
^y::EmacsSend("^v")                     ;yank
^/::EmacsSend("^z")                     ;undo
!<::EmacsSend("^{HOME}", gEmacsShift)   ;beginning of buffer
!>::EmacsSend("^{END}", gEmacsShift)    ;end of buffer

#UseHook Off

;--------------------------------------------------------------------;
; EmacsSend
;--------------------------------------------------------------------;
EmacsSend(_key, _shift=False)
{
    global gEmacsTwoStroke
    global gEmacsShift := _shift

    if (gEmacsTwoStroke)
    {
        Send %A_ThisHotkey%
    }
    else if (_shift)
    {
        Send +%_key%
    }
    else
    {
        Send %_key%
    }
}

;--------------------------------------------------------------------;
; EmacsInput
;--------------------------------------------------------------------;
EmacsInput()
{
    global gEmacsTwoStroke

    ;; C-c, C-x and ESC input at second stroke
    if (gEmacsTwoStroke)
    {
        if (A_ThisHotkey == "ESC")
            Send {ESC}
        else
            Send %A_ThisHotkey%
        return
    }

    gEmacsTwoStroke := True
    Input key, B C M L1 T2,{ESC}
    gEmacsTwoStroke := False

    Transform code, Asc, %key%

    if (ErrorLevel == "EndKey:Escape")
        return "{ESC}"
    else if (ErrorLevel == "Timeout")
        return
    else if (code == 0)
        return "^@"
    else if (code > 0 && code <= 26)
    {
        code := code + 96
        Transform cc, Chr, %code%
        key = ^%cc%
        return %key%
    }
    else if (code == 27)
        return "{ESC}"
    else
        return %key%
}

;--------------------------------------------------------------------;
; C-x
;--------------------------------------------------------------------;
EmacsCtrlX()
{
    global gEmacsShift
    key := EmacsInput()

    if (key == "^s")
        key = ^s                          ;save buffer
    else if (key == "^c")
        key = !{F4}                       ;close window
    else if (key == "m")
    {
        WinActivate, ahk_class rctrl_renwnd32
        key = ^n                          ;compose mail via Outlook
    }

    Send %key%
}
;--- end of file. ---------------------------------------------------;
