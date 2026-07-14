; Testux installer.
;
;   iscc /DAppVersion=0.1.0 packaging\windows\testux.iss
;
; Expects the deployed app in deploy\ (testux.exe + Qt from windeployqt, scripts\, qemu\)
; and writes dist\TestuxSetup-<version>.exe. Both paths are relative to the repository root.

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#ifndef SourceDir
  #define SourceDir "..\..\deploy"
#endif
#ifndef OutputDir
  #define OutputDir "..\..\dist"
#endif

[Setup]
AppId={{8619903B-41C1-46F4-916F-37B84038B4B0}
AppName=Testux
AppVersion={#AppVersion}
AppVerName=Testux {#AppVersion}
AppPublisher=luxend
AppPublisherURL=https://github.com/luxend0/testux
AppSupportURL=https://github.com/luxend0/testux/issues
AppUpdatesURL=https://github.com/luxend0/testux/releases
VersionInfoVersion={#AppVersion}
DefaultDirName={autopf}\Testux
DisableProgramGroupPage=yes
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
; Windows 10 1809, the first release with a usable Windows Hypervisor Platform API
MinVersion=10.0.17763
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
SetupIconFile=testux.ico
UninstallDisplayIcon={app}\testux.exe
UninstallDisplayName=Testux
OutputDir={#OutputDir}
OutputBaseFilename=TestuxSetup-{#AppVersion}

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "de"; MessagesFile: "compiler:Languages\German.isl"

[CustomMessages]
en.EnablingHypervisor=Enabling the Windows Hypervisor Platform so Linux runs fast in a window...
de.EnablingHypervisor=Windows-Hypervisorplattform wird aktiviert, damit Linux im Fenster schnell läuft...
