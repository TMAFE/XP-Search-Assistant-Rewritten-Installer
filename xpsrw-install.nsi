!include "MUI2.nsh"
!include "FileFunc.nsh"
!include "Sections.nsh"
!include "x64.nsh"

!define APPNAME         "XP Search Assistant Rewritten"
!define APPDIRNAME      "XP Search Assistant Rewritten"
!define APPVERSION      "1.0"
!define PUBNAME         "TMAFE"
!define WEBSITE         "https://tmafe.com"
!define UNKEY           "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\${APPNAME}"
!define REG_APPKEY      "Software\\${PUBNAME}\\${APPNAME}"

!ifndef PAYLOAD_DIR
  !define PAYLOAD_DIR "payload"
!endif

SetCompress off
CRCCheck on
XPStyle on
BrandingText "${APPNAME} ${APPVERSION} Installer"

RequestExecutionLevel admin

Name "${APPNAME} ${APPVERSION}"
OutFile "XP_Search_Assistant_Rewritten_Setup_${APPVERSION}.exe"

InstallDir "$PROGRAMFILES\\${APPDIRNAME}"
InstallDirRegKey HKLM "${REG_APPKEY}" "InstallDir"

!ifndef MUI_ICON
  !define MUI_ICON "${NSISDIR}\\Contrib\\Graphics\\Icons\\classic-install.ico"
!endif
!ifndef MUI_UNICON
  !define MUI_UNICON "${NSISDIR}\\Contrib\\Graphics\\Icons\\classic-uninstall.ico"
!endif

!define MUI_ABORTWARNING
!define MUI_COMPONENTSPAGE_SMALLDESC
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_RIGHT
!define MUI_HEADERIMAGE_BITMAP "${PAYLOAD_DIR}\\xpsrwheader.bmp"

Var StartMenuFolder

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${PAYLOAD_DIR}\\license1.txt"
!insertmacro MUI_PAGE_LICENSE "${PAYLOAD_DIR}\\license2.txt"
!insertmacro MUI_PAGE_LICENSE "${PAYLOAD_DIR}\\license3.txt"
!define MUI_PAGE_CUSTOMFUNCTION_PRE PreComponents
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_STARTMENU "Application" $StartMenuFolder
!insertmacro MUI_PAGE_INSTFILES

!define MUI_FINISHPAGE_RUN "$INSTDIR\\XP Search Assistant Rewritten.exe"
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\\_READ_ME_.txt"
!define MUI_FINISHPAGE_LINK "Visit website"
!define MUI_FINISHPAGE_LINK_LOCATION "${WEBSITE}"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_RESERVEFILE_LANGDLL

Section "${APPNAME} (required)" SEC_CORE
  SectionIn RO
  SetOutPath "$INSTDIR"
  File /r "${PAYLOAD_DIR}\\*.*"

  CreateDirectory "C:\Windows\MSAGENT\CHARS"
  CopyFiles /SILENT "$INSTDIR\\rover.acs" "C:\Windows\MSAGENT\CHARS"
  CopyFiles /SILENT "$INSTDIR\\earl.acs" "C:\Windows\MSAGENT\CHARS"
  CopyFiles /SILENT "$INSTDIR\\courtney.acs" "C:\Windows\MSAGENT\CHARS"

  Push "$INSTDIR\\System\\MSAGENTCTL.DLL"
  Call TryReg
  Push "$INSTDIR\\System\\AGENTCTL.DLL"
  Call TryReg

  WriteRegStr HKLM "${REG_APPKEY}" "InstallDir" "$INSTDIR"
  WriteUninstaller "$INSTDIR\\Uninstall.exe"

  WriteRegStr HKLM "${UNKEY}" "DisplayName" "${APPNAME}"
  WriteRegStr HKLM "${UNKEY}" "UninstallString" "$INSTDIR\\Uninstall.exe"
  WriteRegStr HKLM "${UNKEY}" "DisplayIcon" "$INSTDIR\\XP Search Assistant Rewritten.exe"
  WriteRegStr HKLM "${UNKEY}" "DisplayVersion" "${APPVERSION}"
  WriteRegStr HKLM "${UNKEY}" "Publisher" "${PUBNAME}"
  WriteRegStr HKLM "${UNKEY}" "URLInfoAbout" "${WEBSITE}"
SectionEnd

Section "Microsoft Agent 2.0 and components" SEC_AGENT
  DetailPrint "Installing Microsoft Agent runtimes..."
  Push "$INSTDIR\\Runtimes\\Manual\\MSAGENT.EXE"
  Call RunRuntimeQuiet
  Push "$INSTDIR\\Runtimes\\Manual\\tv_enua.exe"
  Call RunRuntimeQuiet
  Push "$INSTDIR\\Runtimes\\Manual\\spchapi.exe"
  Call RunRuntimeQuiet
  Push "$INSTDIR\\Runtimes\\Manual\\spchcpl.exe"
  Call RunRuntimeQuiet

  Push "$INSTDIR\\Runtimes\\SamTTSEngineInstaller.exe"
  Call RunRuntimeQuietSam

  Push "$INSTDIR\\System\\COMDLG32.OCX"
  Call TryReg
  Push "$INSTDIR\\System\\MSAGENTCTL.DLL"
  Call TryReg
  Push "$INSTDIR\\System\\AGENTCTL.DLL"
  Call TryReg
SectionEnd

Section "Shortcuts" SEC_LINKS
  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
    CreateDirectory "$SMPROGRAMS\\$StartMenuFolder"
    CreateShortCut "$SMPROGRAMS\\$StartMenuFolder\\${APPNAME}.lnk" "$INSTDIR\\XP Search Assistant Rewritten.exe"
    CreateShortCut "$SMPROGRAMS\\$StartMenuFolder\\Uninstall ${APPNAME}.lnk" "$INSTDIR\\Uninstall.exe"
    IfFileExists "$INSTDIR\\_READ_ME_.txt" 0 +2
      CreateShortCut "$SMPROGRAMS\\$StartMenuFolder\\README.lnk" "$INSTDIR\\_READ_ME_.txt"
  !insertmacro MUI_STARTMENU_WRITE_END

  CreateShortCut "$DESKTOP\\${APPNAME}.lnk" "$INSTDIR\\XP Search Assistant Rewritten.exe"
SectionEnd

Section "Install Microsoft Agent Scripting Helper" SEC_MASH
  Call RunMASH_SilentOnly
SectionEnd

Function PreComponents
  SectionSetFlags ${SEC_AGENT} ${SF_SELECTED}
FunctionEnd

LangString DESC_SEC_CORE   ${LANG_ENGLISH} "The main ${APPNAME} application and required files."
LangString DESC_SEC_LINKS  ${LANG_ENGLISH} "Start Menu and desktop shortcuts."
LangString DESC_SEC_AGENT  ${LANG_ENGLISH} "Installs Microsoft Agent runtimes, Sam TTS, and registers required controls."
LangString DESC_SEC_MASH   ${LANG_ENGLISH} "Installs MASH to support .MSH files."

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_CORE}  $(DESC_SEC_CORE)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_LINKS} $(DESC_SEC_LINKS)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_AGENT} $(DESC_SEC_AGENT)
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_MASH}  $(DESC_SEC_MASH)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

Section "Uninstall"
  Delete "$DESKTOP\\${APPNAME}.lnk"
  RMDir /r "$SMPROGRAMS\\$StartMenuFolder"
  RMDir /r "$INSTDIR"
  DeleteRegKey HKLM "${UNKEY}"
  DeleteRegKey HKLM "${REG_APPKEY}"
SectionEnd

Function .onInit
  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

Function RunRuntimeQuiet
  Exch $R0
  IfFileExists "$R0" 0 nofile
  ExecWait '"$R0" /Q' $1
  DetailPrint "Ran $R0 -> exit code $1"
  Goto done
nofile:
  DetailPrint "Runtime not found: $R0"
done:
  Pop $R0
FunctionEnd

Function RunRuntimeQuietSam
  Exch $R0
  IfFileExists "$R0" 0 nofile
  ExecWait '"$R0" /Q' $1
  DetailPrint "Ran $R0 (Sam TTS) -> exit code $1"
  Goto done
nofile:
  DetailPrint "Sam TTS runtime not found: $R0"
done:
  Pop $R0
FunctionEnd

Function TryReg
  Exch $0
  IfFileExists "$0" 0 skip
  RegDLL "$0"
  IfErrors 0 +2
    DetailPrint "RegDLL failed: $0 (continuing)"
skip:
  Pop $0
FunctionEnd

Function RunMASH_SilentOnly
  StrCpy $0 "$INSTDIR\\Runtimes\\_mash_full_setup.exe"
  IfFileExists "$0" 0 skipm
  ExecWait '"$0" /silent' $1
  DetailPrint "MASH (/silent) exit code: $1"
  Goto done
skipm:
  DetailPrint "MASH installer not found; skipping! Check your MASH archive if needed."
done:
FunctionEnd
