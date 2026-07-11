#define MyAppName "TachyonVM (Server Edition)"
#define MyAppVersion "25.0"
#define MyAppPublisher "AmiraliT"

[Setup]
AppId={{TACHYONVM-SERVER-1234-5678-ABCD}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\TachyonVM-Server
DefaultGroupName={#MyAppName}
OutputBaseFilename=TachyonVM-Server-Installer-Win64
Compression=lzma2/ultra64
SolidCompression=yes
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
WizardStyle=modern
WizardImageFile=banner.bmp
WizardImageStretch=yes
ChangesEnvironment=yes
DisableWelcomePage=no
LicenseFile=README.md

[Files]
Source: "jdk25-src\build\windows-x86_64-server-release\images\jdk\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Code]
const
  EnvironmentKey = 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment';

procedure CurStepChanged(CurStep: TSetupStep);
var
  Paths: string;
  BinDir: string;
  JavaHome: string;
begin
  if CurStep = ssPostInstall then
  begin
    BinDir := ExpandConstant('{app}\bin');
    JavaHome := ExpandConstant('{app}');
    
    { Set JAVA_HOME }
    RegWriteExpandStringValue(HKEY_LOCAL_MACHINE, EnvironmentKey, 'JAVA_HOME', JavaHome);
    
    { Update PATH }
    if RegQueryStringValue(HKEY_LOCAL_MACHINE, EnvironmentKey, 'Path', Paths) then
    begin
      if Pos(';' + BinDir + ';', ';' + Paths + ';') = 0 then
      begin
        if Paths[Length(Paths)] <> ';' then Paths := Paths + ';';
        Paths := Paths + BinDir;
        RegWriteExpandStringValue(HKEY_LOCAL_MACHINE, EnvironmentKey, 'Path', Paths);
      end;
    end;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  Paths: string;
  BinDir: string;
begin
  if CurUninstallStep = usUninstall then
  begin
    BinDir := ExpandConstant('{app}\bin');
    
    { Remove JAVA_HOME }
    RegDeleteValue(HKEY_LOCAL_MACHINE, EnvironmentKey, 'JAVA_HOME');
    
    { Remove from PATH }
    if RegQueryStringValue(HKEY_LOCAL_MACHINE, EnvironmentKey, 'Path', Paths) then
    begin
      StringChangeEx(Paths, BinDir + ';', '', True);
      StringChangeEx(Paths, ';' + BinDir, '', True);
      StringChangeEx(Paths, BinDir, '', True);
      RegWriteExpandStringValue(HKEY_LOCAL_MACHINE, EnvironmentKey, 'Path', Paths);
    end;
  end;
end;
