; Testux installer.

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

[Code]
var
  HypervisorNeedsRestart: Boolean;

function HypervisorPlatformEnabled(): Boolean;
var
  ResultCode: Integer;
begin
  // The State enum name is not localized, unlike the text output of dism /get-featureinfo.
  Result := Exec(ExpandConstant('{sysnative}\WindowsPowerShell\v1.0\powershell.exe'),
    '-NoProfile -NonInteractive -Command "if ((Get-WindowsOptionalFeature -Online ' +
    '-FeatureName HypervisorPlatform).State -eq ''Enabled'') { exit 0 } else { exit 1 }"',
    '', SW_HIDE, ewWaitUntilTerminated, ResultCode) and (ResultCode = 0);
end;

procedure EnableHypervisorPlatform();
var
  ResultCode: Integer;
begin
  if HypervisorPlatformEnabled() then
  begin
    Log('Windows Hypervisor Platform already enabled');
    Exit;
  end;

  WizardForm.StatusLabel.Caption := CustomMessage('EnablingHypervisor');
  // 3010 = enabled, takes effect after a restart. On failure Testux still works, only
  // slower, and tells the user how to turn the feature on.
  if Exec(ExpandConstant('{sysnative}\dism.exe'),
      '/online /enable-feature /featurename:HypervisorPlatform /all /norestart /quiet',
      '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
  begin
    HypervisorNeedsRestart := ResultCode = 3010;
    Log(Format('dism enable HypervisorPlatform exit code %d', [ResultCode]));
  end
  else
    Log(Format('Could not run dism: %s', [SysErrorMessage(ResultCode)]));
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
    EnableHypervisorPlatform();
end;

function NeedRestart(): Boolean;
begin
  Result := HypervisorNeedsRestart;
end;
