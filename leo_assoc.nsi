;@+leo-ver=5-thin
;@+node:ekr.20160510090441.1: * @file ../../leo_assoc.nsi
;@@language nsi

;##version
!define version         "5.3-final"

!include MUI2.nsh
!include nsDialogs.nsh
!include LogicLib.nsh

!define app_icon        "leo\Icons\LeoApp.ico"
!define doc_icon        "leo\Icons\LeoDoc.ico"
!define ext             ".leo"
!define leo_hklm        "SOFTWARE\EKR\Leo"
!define license         "License.txt"
!define name            "Leo"
!define publisher       "Edward K. Ream"
!define site            "http://leoeditor.com/"
!define target_file     "LeoAssoc.exe"
!define uninst_key      "Software\Microsoft\Windows\CurrentVersion\Uninstall\leo"

;;;!include nsi-boilerplate.txt

;@+<< assoc prolog >>
;@+node:ekr.20160510090943.1: ** << assoc prolog >>
; Globals.
Var PythonDirectory
    ; Directory containing Pythonw.exe
    ; Set by onInit.  May be set in Python Directory page.

!define PythonExecutable "$PythonDirectory\pythonw.exe"
    ;;; Always use pythonw.exe here.
    ;;; To debug, set the target to python.exe in the desktop icon properties.

!addincludedir C:\leo.repo\leo-editor\leo\dist

; Boilerplate
SetCompressor bzip2
Caption "Leo File Associations Installer"
AutoCloseWindow false 
SilentInstall normal
CRCCheck on
SetCompress auto
SetDatablockOptimize on
WindowIcon on
ShowInstDetails show
ShowUnInstDetails show

; Locations
Name "${name}"
OutFile "LeoAssoc.exe"
;;;InstallDir "$PROGRAMFILES\${name}-${version}"

; Icons
;!define MUI_ICON "${icon}"
;@-<< assoc prolog >>
;@+<< assoc pages >>
;@+node:ekr.20160510091130.1: ** << assoc pages >>
;@@language nsi

Var StartMenuFolder

; Define the TEXT_TOP for both the MUI_PAGE_DIRECTORY pages.
; "${s1a} ${s2} ${s3}" is the TEXT_TOP for the Install Location page.
; "${s2b} ${s2} ${s3}" is the TEXT_TOP for the Choose Python Folder page.
!define s1a "Setup will install File Associations for Leo in the Windows registery."
!define s1b "Setup will use the following folder as the Python location."
!define s2 "To install in a different folder, click Browse and select another folder."
!define s3 "Click next to continue."

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE       ${license}
!insertmacro MUI_PAGE_COMPONENTS

; These are the defaults, but defined them here so the back button works.
!define MUI_PAGE_HEADER_TEXT "Choose Installed Location"
!define MUI_PAGE_HEADER_SUBTEXT "Choose the folder in which Leo has been installed."
!define MUI_DIRECTORYPAGE_TEXT_TOP "${s1a} ${s2} ${s3}"
!define MUI_DIRECTORYPAGE_TEXT_DESTINATION "Installation Folder"
!insertmacro MUI_PAGE_DIRECTORY

; It's so easy: just set these *before* creating another directory page!
!define MUI_PAGE_HEADER_TEXT "Choose Python Location"
!define MUI_PAGE_HEADER_SUBTEXT "Select the top-level Python directory"
!define MUI_DIRECTORYPAGE_TEXT_TOP "${s1b} ${s2} ${s3}"
!define MUI_DIRECTORYPAGE_TEXT_DESTINATION "Python Folder"
!define MUI_DIRECTORYPAGE_VARIABLE $PythonDirectory
!insertmacro MUI_PAGE_DIRECTORY

!insertmacro MUI_PAGE_STARTMENU "Application" $StartMenuFolder
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; ----- uninstaller pages -----

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_DIRECTORY
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH
;@-<< assoc pages >>
;@+others
;@+node:ekr.20160510093336.1: ** onInit
; Set PythonDirectory to the top-level Python path.
; For now, prefer Python 2.x to Python 3.x.
Function .onInit
    ;try27:
        ReadRegStr $9 HKLM "SOFTWARE\Python\PythonCore\2.7\InstallPath" ""
        ;MessageBox MB_OK $9
        StrCmp $9 "" try26 ok
    try26:
        ReadRegStr $9 HKLM "SOFTWARE\Python\PythonCore\2.6\InstallPath" ""
        StrCmp $9 "" try35 ok
    try35:
        ReadRegStr $9 HKLM "SOFTWARE\Python\PythonCore\3.5\InstallPath" ""
        StrCmp $9 "" try34 ok
    try34:
        ReadRegStr $9 HKLM "SOFTWARE\Python\PythonCore\3.4\InstallPath" ""
        StrCmp $9 "" try33 ok
    try33:
        ReadRegStr $9 HKLM "SOFTWARE\Python\PythonCore\3.3\InstallPath" ""
        StrCmp $9 "" try32 ok
    try32:
        ReadRegStr $9 HKLM "SOFTWARE\Python\PythonCore\3.2\InstallPath" ""
        StrCmp $9 "" try31 ok
    try31:
        ReadRegStr $9 HKLM "SOFTWARE\Python\PythonCore\3.1\InstallPath" ""
        StrCmp $9 "" try30 ok
    try30:
        ReadRegStr $9 HKLM "SOFTWARE\Python\PythonCore\3.0\InstallPath" ""
        StrCmp $9 "" oops ok
    oops:
        MessageBox MB_OK "Python not found"
        ;;;StrCpy $PythonDirectory ""
        StrCpy $PythonDirectory "c:\Anaconda2"
            ; Problems with pythonw with Python3.
        Goto done
    ok:
        StrCpy $PythonDirectory $9
    done:
FunctionEnd ; End .onInit
;@+node:ekr.20160510093344.1: ** LeoAssoc
; The name of this section must be "Leo".
Section "LeoAssoc" SEC01
    ;;;
SectionEnd
;@+node:ekr.20160510093411.1: ** FileAssociation
Section "${ext} File Association" SEC02
    SectionIn 1 2 3 4
    WriteRegStr HKCR "${ext}" "" "${name}File"
    WriteRegStr HKCR "${name}File" "" "${name} File"
    WriteRegStr HKCR "${name}File\shell" "" "open"
    ; The single quotes below appear to be required.
    WriteRegStr HKCR "${name}File\DefaultIcon" "" '"$INSTDIR\${app_icon}"'
        ; https://github.com/leo-editor/leo-editor/issues/24
    WriteRegStr HKCR "${name}File\shell\open\command" "" '"${PythonExecutable}" "$INSTDIR\launchLeo.py %*"'
SectionEnd
;@+node:ekr.20160510093822.1: ** Section Desktop Shortcut

Section "${name} Desktop Shortcut" SEC03
  ; This sets the "Start in folder" box!!!"
  SetOutPath "$INSTDIR\leo"
  ;;; This is **tricky**.  We need single quotes to handle paths containing spaces.
  ;;; Add single quotes around PythonExecutable and launchLeo.py args, but *not* the app_icon arg.
  CreateShortCut "$DESKTOP\${name}.lnk" '"${PythonExecutable}"' '"$INSTDIR\launchLeo.py"' "$INSTDIR\${app_icon}"
SectionEnd
;@+node:ekr.20160510093859.1: ** Section Start Menu

Section "${name} Start Menu" SEC04
  CreateDirectory "$SMPROGRAMS\${name}"
  ;;; This is **tricky**.  We need single quotes to handle paths containing spaces.
  ;;; Add single quotes around PythonExecutable and launchLeo.py args, but *not* the app_icon arg.
  CreateShortCut "$SMPROGRAMS\${name}\${name}.lnk" '"${PythonExecutable}"' '"$INSTDIR\launchLeo.py"' "$INSTDIR\${app_icon}"
  CreateShortCut "$SMPROGRAMS\${name}\Uninstall.lnk" '"$INSTDIR\uninst.exe"'
SectionEnd
;@+node:ekr.20160510095711.1: ** Section -Post

Section -Post
  WriteRegStr HKLM ${leo_hklm} "" "$INSTDIR"
  WriteUninstaller "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${uninst_key}" "DisplayName" "${name}-${version}-associations (remove only)"
  WriteRegStr HKLM "${uninst_key}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr HKLM "${uninst_key}" "DisplayVersion" "${version}-associations"
  WriteRegStr HKLM "${uninst_key}" "URLInfoAbout" "${site}"
  WriteRegStr HKLM "${uninst_key}" "Publisher" "${publisher}"
SectionEnd
;@+node:ekr.20160510095724.1: ** Section Uninstall

Section Uninstall
    DeleteRegKey HKLM "${leo_hklm}"
    DeleteRegKey HKCR "${ext}"
    DeleteRegKey HKCR "${name}File"
    ; Remove links.
    Delete "$SMPROGRAMS\${name}\Uninstall.lnk"
    Delete "$SMPROGRAMS\${name}.lnk"
    Delete "$DESKTOP\${name}.lnk"
    DeleteRegKey HKLM "${uninst_key}" 
    SetAutoClose false

SectionEnd ; end Uninstall section
;@-others
; Language should follow pages.
!insertmacro MUI_LANGUAGE "English"
;@-leo
