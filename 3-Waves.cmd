@echo off
%~d0
CD %~dp0

for /f "tokens=6 delims=[]. " %%# in ('ver') do if %%# geq 7600 (
		echo This script is for Vista/WS2008 only.
		pause && exit
)

:: IE9 Cummulative update kb number
set IE9KB=kb5055515
:: 's' for shutdown, 'r' for restart
set "shutdown_mode=r"
set "shutdown_timer=60"
set "ping_timer=10"

::XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
if defined PROCESSOR_ARCHITEW6432 start "" %SystemRoot%\Sysnative\cmd.exe /c "%0 " &exit
set "arch=x86"
if exist "%WinDir%\SysWOW64" set "arch=x64"
::XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


::WAVE1
if not exist "%~dp0WAVE1.txt" (
	echo Wave1
	for /d %%a in (10*) do (
		echo ===============================================================================
		echo			[%%a]
		echo ===============================================================================

		pushd %%a
		for %%f in ("*%arch%*.msu") do (
			for /f "tokens=2 delims=-" %%A in ('echo "%%f"') do (
				if exist "%SystemRoot%\servicing\packages\package_*_for_%%A*.mum" (
					echo %%A exist, skipping...
				) else (
					echo %%A missing, installing...
					Wusa.exe %%f /quiet /norestart
					echo %%A>>"%~dp0log.txt"
				)
			)
		)
		popd
		echo.
	)
	
	echo DONE>"%~dp0WAVE1.txt"
)

if exist "%SystemRoot%\WinSxS\pending.xml" (goto :RESTART)
::XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

::WAVE2
if not exist "%~dp0WAVE2.txt" (
	echo Wave2

	if exist "%~dp0211-Installations\" (
		pushd "%~dp0211-Installations"
		::IE9 Conditional Installation
		for /f "usebackq tokens=3 delims= " %%f in (`reg query "HKLM\Software\Microsoft\Internet Explorer" /v Version 2^>nul`) do (
		REM for /f "tokens=3" %%v in ('Reg Query "HKLM\Software\Microsoft\Internet Explorer" /v "Version" 2^>Nul') do set "version=%%v"
			if not %%f == 9.0.8112.16421 (
				echo IE9 is missing, installing...
				for %%i in (*kb0982861-%arch%*.exe) do (
					%%i /quiet /passive /update-no /norestart
					echo %%i>>"%~dp0log.txt"
					echo restart>"%~dp0RESTART.txt"
				)
			)
		)
		popd
	)
	
	if exist "%~dp0211-Repacks\" (
		pushd "%~dp0211-Repacks"
		::dotNet 3.5 Repack. Will always attempt to install. 
		echo dotNet 3.5 Repack will be installed if it is not already installed.
		for %%f in (dotNetFx35_x86_x64.exe) do (%%f -ai -gm2 -qn -x99 && echo %%f>>"%~dp0log.txt")
		::dotNet 4.6.2 Repack. Will always attempt to install.
		echo dotNet 4.6.2 Repack will be installed if it is not already installed.
		for %%f in (NDP462-x86-x64-ENU.exe) do (%%f -ai -gm2 -qn -x99 && echo %%f>>"%~dp0log.txt")
		popd
	)

	for /d %%a in (20*) do (

		echo ===============================================================================
		echo			[%%a]
		echo ===============================================================================

		pushd %%a
		for %%f in ("*%arch%*.msu") do (
			for /f "tokens=2 delims=-" %%A in ('echo "%%f"') do (
				if exist "%SystemRoot%\servicing\packages\package_*_for_%%A*.mum" (
					echo %%A exist, skipping...
				) else (
					echo %%A missing, installing...
					Wusa.exe %%f /quiet /norestart
					echo %%A>>"%~dp0log.txt"
				)
			)
		)
		popd
		echo.
	)

	echo DONE>"%~dp0WAVE2.txt"
)

if exist "%~dp0RESTART.txt" (goto :RESTART)
if exist "%SystemRoot%\WinSxS\pending.xml" (goto :RESTART)

::XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

::WAVE3
if exist "%~dp0WAVE3.txt" (goto :WAVE4) else (echo Wave3)

for /d %%a in (30*) do (

	echo ===============================================================================
	echo			[%%a]
	echo ===============================================================================

	pushd %%a
	for %%f in ("*%arch%*.msu") do (
		for /f "tokens=2 delims=-" %%A in ('echo "%%f"') do (
			if exist "%SystemRoot%\servicing\packages\package_*_for_%%A*.mum" (
				echo %%A exist, skipping...
			) else (
				echo %%A missing, installing...
				Wusa.exe %%f /quiet /norestart
				echo %%A>>"%~dp0log.txt"
			)
		)
	)
	popd
	echo.
)

if exist "%~dp0314-IE9-CU\" (
	pushd "%~dp0314-IE9-CU\"
	if exist *.msu (
		echo ================================================================================
		echo			[Internet Explorer 9 Cumulative Update]
		echo ================================================================================
			
		if "%arch%" == "x86" (
			for %%f in (*%IE9KB%-%arch%*.msu) do (
				for /f "tokens=2 delims=-" %%A in ('echo "%%f"') do (
					if exist "%SystemRoot%\servicing\packages\package_*_for_%%A*.mum" (
						echo %%A exist, skipping...
					) else (
						echo %%f missing, installing...
						Wusa.exe %%f /quiet /norestart
						echo IE9-%IE9KB%>>"%~dp0log.txt"
					)
				)
			)
		)

		if "%arch%" == "x64" (
			mkdir tmp"
			for /f "usebackq delims=|" %%f in (`dir /b "%~dp0314-IE9-CU\" ^| findstr /i windows6.0-%IE9KB%-%arch%`) do copy %%f "%~dp0314-IE9-CU\tmp" >nul
			pushd "%~dp0314-IE9-CU\tmp"
			expand -f:*windows6.0-kb*.cab *.msu "%~dp0314-IE9-CU\tmp" >nul
			expand -f:* *.cab "%~dp0314-IE9-CU\tmp" >nul
			for /f %%f in ('dir /b "package_*_for_*.mum"') do findstr /i ExtendedSecurityUpdatesAI %%f >nul || (
				if exist "%SystemRoot%\servicing\packages\%%f" (
					echo %%f exists, skipping...
				) else (
					echo %%f
					start /wait pkgmgr /ip /m:%%f /quiet /norestart
					echo restart>"%~dp0RESTART.txt"
					echo IE9-%IE9KB%>>"%~dp0log.txt"
				)
			)
			popd
			rmdir /s /q "tmp"
		)
	)
	popd

	Reg.exe delete "HKLM\SOFTWARE\Microsoft\Internet Explorer\AdvancedOptions\CRYPTO\TLS1.1" /v "OSVersion" /f 2>nul
	Reg.exe delete "HKLM\SOFTWARE\Microsoft\Internet Explorer\AdvancedOptions\CRYPTO\TLS1.2" /v "OSVersion" /f 2>nul
	Reg.exe delete "HKLM\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\AdvancedOptions\CRYPTO\TLS1.1" /v "OSVersion" /f 2>nul
	Reg.exe delete "HKLM\SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\AdvancedOptions\CRYPTO\TLS1.2" /v "OSVersion" /f 2>nul
)

echo DONE>"%~dp0WAVE3.txt"
if exist "%~dp0RESTART.txt" (goto :RESTART)
if exist "%SystemRoot%\WinSxS\pending.xml" (goto :RESTART)

::XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

:WAVE4
if exist "%~dp0WAVE4.txt" (goto :WAVE5) else (echo Wave4)

if exist "%WinDir%\SysWOW64" (set "xBT=amd64") else (set "xBT=x86")
if exist "%SystemRoot%\Servicing\Packages\Package_25_for_KB4474419*.mum" (
	reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages\Package_25_for_KB4474419~31bf3856ad364e35~%xBT%~~6.0.4.0" /v CurrentState 2>nul | find /i "0x7" 1>nul && (
		goto :SectionEnd
	)
)

echo ===============================================================================
echo			[Vista_SHA2_WUC - Installing...]
echo ===============================================================================
pushd "%~dp0406-Vista_SHA2_WUC"

@setlocal DisableDelayedExpansion
@echo off
REM if defined PROCESSOR_ARCHITEW6432 start "" %SystemRoot%\Sysnative\cmd.exe /c "%0 " &exit
set "SysPath=%SystemRoot%\System32"
set "Path=%SysPath%;%SystemRoot%;%SysPath%\Wbem;%SysPath%\WindowsPowerShell\v1.0\"

set "_err===== ERROR ===="
for /f "tokens=6 delims=[]. " %%# in ('ver') do if %%# geq 7600 goto :E_Win
reg query HKU\S-1-5-19 1>nul 2>nul || goto :E_Admin

set "_wrn===== WARNING ===="
set "_CBS=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages"
set "xOS=64"
set "xBT=amd64"
if /i %PROCESSOR_ARCHITECTURE%==x86 (if not defined PROCESSOR_ARCHITEW6432 (
  set "xOS=32"
  set "xBT=x86"
  )
)
set "_bat=%~f0"
set "_arg=%~1"
set "_elv="
if defined _arg if /i "%_arg%"=="-su" set _elv=1

set "_work=%~dp0"
set "_work=%_work:~0,-1%"
setlocal EnableDelayedExpansion
REM pushd "!_work!"
if not exist "%xOS%\" (
echo %_err%
echo Required folder %xOS% is missing.
goto :SectionEnd
)
cd %xOS%\
for %%# in (
NSudoLC.exe
) do if not exist "%%~#" (
echo %_err%
echo Required file %xOS%\%%~nx# is missing.
goto :SectionEnd
)

call :TIcmd 1>nul 2>nul
whoami /USER | find /i "S-1-5-18" 1>nul && (
goto :Begin
) || (
if defined _elv goto :E_TI
net start TrustedInstaller 1>nul 2>nul
1>nul 2>nul NSudoLC.exe -U:T -P:E cmd.exe /c ""!_bat!" -su" &exit /b
)
whoami /USER | find /i "S-1-5-18" 1>nul || goto :E_TI

:Begin
set "PKGS=%SystemRoot%\Servicing\Packages"
if exist "%PKGS%\Microsoft-Windows-Foundation-Package*6.0.6001.18000.mum" goto :E_Win

if exist "%PKGS%\Package_25_for_KB4474419*.mum" reg query "%_CBS%\Package_25_for_KB4474419~31bf3856ad364e35~%xBT%~~6.0.4.0" /v CurrentState 2>nul | find /i "0x7" 1>nul && (
goto :SectionEnd
)

if exist "%SystemRoot%\WinSxS\pending.xml" (
goto :RESTART
)

if not exist "%PKGS%\Package_for_KB4474419*.mum" (
echo %_err%
echo Required update KB4474419 is missing.
echo You must install it first.
pause && exit
)

if not exist "%PKGS%\Package_for_KB4493730*.mum" (
echo %_err%
echo Required update KB4493730 is missing.
echo You must install it first.
pause && exit
)

set "_LPS=2:cs-CZ 3:de-DE 4:en-US 5:es-ES 6:fr-FR 7:hu-HU 8:it-IT 9:ja-JP 10:ko-KR 11:nl-NL 12:pl-PL 13:pt-BR 14:pt-PT 15:ru-RU 16:sv-SE 17:tr-TR 18:zh-CN 19:zh-HK 19:zh-TW"
set _spt=0
for %%# in (
%_LPS%
) do for /f "tokens=1,2 delims=:" %%A in ("%%#") do (
if exist "%PKGS%\Microsoft-Windows-Client-LanguagePack-Package*%%B*.mum" set _spt=1
)
if %_spt% equ 0 (
echo %_err%
echo No supported Language Pack detected.
echo Refer to ReadMe for more info.
pause
exit
)

set "KSHA=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Servicing\Codesigning\SHA2"
reg query %KSHA% 2>nul | find /i "SHA2-Codesigning-Support" 1>nul || (
reg add %KSHA% /v SHA2-Codesigning-Support /t REG_DWORD /d 1 /f 1>nul 2>nul
reg add %KSHA% /v SHA2-Core-Codesigning-Support /t REG_DWORD /d 1 /f 1>nul 2>nul
)

echo.
echo ____________________________________________________________
echo.
echo Installing Windows Update Client . . .
echo.

::XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
echo WUC 7.7>>"%~dp0log.txt"
echo RESTART>"%~dp0RESTART.txt"
::XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

call :StopService wuauserv 1>nul 2>nul
set errcode=0
for %%# in (
%_LPS%
) do for /f "tokens=1,2 delims=:" %%A in ("%%#") do (
if exist "%PKGS%\Microsoft-Windows-Client-LanguagePack-Package*%%B*.mum" (
  call :AddCBS %%B 1>nul 2>nul
  start /w PkgMgr.exe /ip /m:"WUC\Package_%%A_for_KB4474419~31bf3856ad364e35~%xBT%~~6.0.4.0.mum" /quiet /norestart 1>nul 2>nul
  call set errcode=!errorlevel!
  )
)
if %errcode% neq 0 if %errcode% neq 3010 (
echo.&echo %_err%
echo Installing language packages failed.
goto :Failure
)
for /L %%# in (2,1,19) do if exist "%PKGS%\Package_%%#_for_KB4474419~31bf3856ad364e35~%xBT%~~6.0.4.0.mum" (
reg add "%_CBS%\Package_%%#_for_KB4474419~31bf3856ad364e35~%xBT%~~6.0.4.0" /v Visibility /t REG_DWORD /d 2 /f 1>nul 2>nul
)
call :AddCBS 1>nul 2>nul
start /w PkgMgr.exe /ip /m:"WUC\Package_25_for_KB4474419~31bf3856ad364e35~%xBT%~~6.0.4.0.mum" /quiet /norestart 1>nul 2>nul
call set errcode=%errorlevel%
if %errcode% neq 0 if %errcode% neq 3010 (
echo.&echo %_err%
echo Installing main package failed.
goto :Failure
)
reg add "%_CBS%\Package_25_for_KB4474419~31bf3856ad364e35~%xBT%~~6.0.4.0" /v Visibility /t REG_DWORD /d 2 /f 1>nul 2>nul
call :RemCBS 1>nul 2>nul

goto :SectionEnd

:AddCBS
if "%1"=="" (
set "pkg=Microsoft-Windows-Foundation-Package~31bf3856ad364e35~%xBT%~~6.0.6001.18000"
) else (
set "pkg=Microsoft-Windows-Client-LanguagePack-Package~31bf3856ad364e35~%xBT%~%1~6.0.6001.18000"
)
copy /y CBS\%pkg%.* %PKGS%
reg add "%_CBS%\%pkg%" /f /v CurrentState /t REG_DWORD /d 0x7 &reg add "%_CBS%\%pkg%" /f /v InstallClient /t REG_SZ /d "Package Manager" &reg add "%_CBS%\%pkg%" /f /v InstallLocation /t REG_SZ /d \\?\C:\Packages\ &reg add "%_CBS%\%pkg%" /f /v InstallName /t REG_SZ /d %pkg%.mum &reg add "%_CBS%\%pkg%" /f /v InstallTimeHigh /t REG_DWORD /d 0x1c6fe94 &reg add "%_CBS%\%pkg%" /f /v InstallTimeLow /t REG_DWORD /d 0x5b437864 &reg add "%_CBS%\%pkg%" /f /v InstallUser /t REG_SZ /d S-1-5-18 &reg add "%_CBS%\%pkg%" /f /v SelfUpdate /t REG_DWORD /d 0x0 &reg add "%_CBS%\%pkg%" /f /v Trusted /t REG_DWORD /d 0x1 &reg add "%_CBS%\%pkg%" /f /v Visibility /t REG_DWORD /d 0x1 &reg add "%_CBS%\%pkg%\Owners" /f /v %pkg% /t REG_DWORD /d 0x20007
exit /b

:RemCBS
del /f /q %PKGS%\Microsoft-Windows-Foundation-Package~31bf3856ad364e35~%xBT%~~6.0.6001.18000.*
reg delete "%_CBS%\Microsoft-Windows-Foundation-Package~31bf3856ad364e35~%xBT%~~6.0.6001.18000" /f
for %%# in (
%_LPS%
) do for /f "tokens=1,2 delims=:" %%A in ("%%#") do (
del /f /q %PKGS%\Microsoft-Windows-Client-LanguagePack-Package~31bf3856ad364e35~%xBT%~%%B~6.0.6001.18000.*
reg delete "%_CBS%\Microsoft-Windows-Client-LanguagePack-Package~31bf3856ad364e35~%xBT%~%%B~6.0.6001.18000" /f
)
exit /b

:StopService
sc query %1 | find /i "STOPPED" || net stop %1 /y
sc query %1 | find /i "STOPPED" || sc stop %1
exit /b

:TIcmd
reg add HKU\.DEFAULT\Console /f /v FaceName /t REG_SZ /d Consolas
reg add HKU\.DEFAULT\Console /f /v FontFamily /t REG_DWORD /d 0x36
reg add HKU\.DEFAULT\Console /f /v FontSize /t REG_DWORD /d 0x100000
reg add HKU\.DEFAULT\Console /f /v FontWeight /t REG_DWORD /d 0x190
reg add HKU\.DEFAULT\Console /f /v ScreenBufferSize /t REG_DWORD /d 0x12c0050
exit /b

:E_TI
echo %_err%
echo Failed running the script with TrustedInstaller privileges.
goto :End

:E_Admin
echo %_err%
echo This script requires administrator privileges.
pause && exit

:E_Win
echo %_err%
echo This project is for Windows Vista only.
pause && exit

:Failure
if exist "%PKGS%\Package_25_for_KB4474419~31bf3856ad364e35~%xBT%~~6.0.4.0.mum" (
start /w PkgMgr.exe /up:"Package_25_for_KB4474419~31bf3856ad364e35~%xBT%~~6.0.4.0" /quiet /norestart 1>nul 2>nul
)
for /L %%# in (2,1,19) do if exist "%PKGS%\Package_%%#_for_KB4474419~31bf3856ad364e35~%xBT%~~6.0.4.0.mum" (
start /w PkgMgr.exe /up:"Package_%%#_for_KB4474419~31bf3856ad364e35~%xBT%~~6.0.4.0" /quiet /norestart 1>nul 2>nul
)
call :RemCBS 1>nul 2>nul
pause && exit

:SectionEnd
popd

echo DONE>"%~dp0WAVE4.txt"
if exist "%SystemRoot%\WinSxS\pending.xml" (goto :RESTART)
if exist "%~dp0RESTART.txt" (goto :RESTART)

::XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

:WAVE5
if exist WAVE5.txt (goto :WAVE6) else (echo Wave5)

if exist "%SystemRoot%\System32\kerneles.dll" (goto :SectionEnd)

echo ===============================================================================
echo			[Vista_SHA2_WUC - Patching as Vista + WS2008]
echo ===============================================================================

pushd "%~dp0406-Vista_SHA2_WUC"

@setlocal DisableDelayedExpansion
@echo off
::if defined PROCESSOR_ARCHITEW6432 start "" %SystemRoot%\Sysnative\cmd.exe /c "%0 " &exit
set "SysPath=%SystemRoot%\System32"
set "Path=%SysPath%;%SystemRoot%;%SysPath%\Wbem;%SysPath%\WindowsPowerShell\v1.0\"

set "_err===== ERROR ===="
for /f "tokens=6 delims=[]. " %%# in ('ver') do if %%# geq 7600 goto :E_Win
reg query HKU\S-1-5-19 1>nul 2>nul || goto :E_Admin

set "_EDT=HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
set "_SVC=HKLM\SYSTEM\CurrentControlSet\Services\wuauserv\Parameters"
set "xOS=64"
set "xBT=amd64"
if /i %PROCESSOR_ARCHITECTURE%==x86 (if not defined PROCESSOR_ARCHITEW6432 (
  set "xOS=32"
  set "xBT=x86"
  )
)
set "_bat=%~f0"
set "_arg=%~1"
set "_elv="
if defined _arg if /i "%_arg%"=="-su" set _elv=1

set "_work=%~dp0"
set "_work=%_work:~0,-1%"
setlocal EnableDelayedExpansion
::pushd "!_work!"
if not exist "%xOS%\" (
echo %_err%
echo Required folder %xOS% is missing.
goto :SectionEnd
)
cd %xOS%\
for %%# in (
bbe.exe kernelesA.dll kernelesS.dll kernelesV.dll sle.dll
) do if not exist "%%~#" (
echo %_err%
echo Required file %xOS%\%%~nx# is missing.
goto :SectionEnd
)

:Begin
set "PKGS=%SystemRoot%\Servicing\Packages"
if exist "%PKGS%\Microsoft-Windows-Foundation-Package*6.0.6001.18000.mum" goto :E_Win

set "_ver=7.6.7600.256"
set "_file=%SysPath%\wuaueng.dll"
for /f "tokens=2 delims==" %%i in ('wmic /output:stdout datafile where "name='%_file:\=\\%'" get Version /value ^| find "="') do set "_ver=%%i"
if %_ver:~2,1% lss 7 goto :E_WUver
if %_ver:~2,1% equ 7 if %_ver:~4,4% lss 6003 goto :E_WUver
if %_ver:~2,1% equ 7 if %_ver:~4,4% equ 6003 if %_ver:~9% lss 20555 goto :E_WUver

::XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

if "%arch%" == "x64" (
	echo Patching WUC as Vista+WS2008
	echo "WUC set to Option 3">>"%~dp0log.txt"
	set "_DLL=kernelesA.dll"&goto :PatchWU
)

if "%arch%" == "x86" (
	echo Patching wuc as WS2008
	echo "WUC set to Option 2">>"%~dp0log.txt"
	set "_DLL=kernelesS.dll"&goto :PatchWU
)

:PatchWU
call :StopService wuauserv 1>nul 2>nul
if exist "%SystemRoot%\WuEsu\" rmdir /s /q "%SystemRoot%\WuEsu\"
1>nul 2>nul schtasks /Delete /F /TN "Patch WU ESU"

1>nul 2>nul copy /y %_DLL% %SysPath%\kerneles.dll
if /i %_DLL%==kernelesV.dll (
if exist "%SysPath%\sle.dll" del /f /q "%SysPath%\sle.dll"
1>nul 2>nul bbe.exe -e "s/KERNEL32/KERNELES/" -e "s/kernel32/kerneles/" -o %SysPath%\wuaueng6.dll %SysPath%\wuaueng.dll
) else (
1>nul 2>nul copy /y sle.dll %SysPath%\sle.dll
1>nul 2>nul bbe.exe -e "s/KERNEL32/KERNELES/" -e "s/kernel32/kerneles/" -e "s/\x73\x00\x6C\x00\x63\x00\x2E\x00\x64\x00\x6C\x00\x6C\x00/\x73\x00\x6C\x00\x65\x00\x2E\x00\x64\x00\x6C\x00\x6C\x00/" -o %SysPath%\wuaueng6.dll %SysPath%\wuaueng.dll
)
1>nul 2>nul reg add "%_SVC%" /f /v ServiceDll /t REG_EXPAND_SZ /d ^%%SystemRoot^%%\System32\wuaueng6.dll

set "_ebak="
for /f "skip=2 tokens=2*" %%a in ('reg query "%_EDT%" /v EditionID 2^>nul') do set "_ebak=%%b"
reg query "%_EDT%" /v EditionID_bak 1>nul 2>nul && for /f "skip=2 tokens=2*" %%a in ('reg query "%_EDT%" /v EditionID_bak 2^>nul') do set "_ebak=%%b"

if /i %_DLL%==kernelesV.dll (
1>nul 2>nul reg add "%_EDT%" /f /v EditionID /d %_ebak%
1>nul 2>nul reg delete "%_EDT%" /f /v EditionID_bak
) else (
1>nul 2>nul reg add "%_EDT%" /f /v EditionID /d ServerStandard
1>nul 2>nul reg add "%_EDT%" /f /v EditionID_bak /d %_ebak%
)

echo RESTART>"%~dp0RESTART.txt"
goto :SectionEnd

:StopService
sc query %1 | find /i "STOPPED" || net stop %1 /y
sc query %1 | find /i "STOPPED" || sc stop %1
exit /b

:E_Admin
echo %_err%
echo This script requires administrator privileges.
pause && exit

:E_Win
echo %_err%
echo This project is for Windows Vista only.
pause && exit

:E_WUver
echo %_err%
echo wuaueng.dll version not supported
echo Minimum : 7.7.6003.20555
echo Detected: %_ver%
echo.
echo You should reboot after running Install_WUC.cmd
echo or verify that WinMgmt service is working properly.
pause && exit

:SectionEnd
popd

echo DONE>"%~dp0WAVE5.txt"
if exist "%SystemRoot%\WinSxS\pending.xml" (goto :RESTART)
if exist "%~dp0RESTART.txt" (goto :RESTART)

::XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
::XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX


:WAVE6
if exist "%~dp0WAVE6.txt" (goto :WAVE7) else (echo Wave6)

REM echo================================================================================
REM echo		[WU_DataStore_Fix INSTALLATION]
REM echo================================================================================

REM pushd 408-WU_DataStore_Fix 2>nul

REM @setlocal DisableDelayedExpansion
REM @echo off
REM set "_args=%*"
REM set "_elv="
REM if not defined _args goto :NoProgArgs
REM if "%~1"=="" set "_args="&goto :NoProgArgs
REM set _args=%_args:"=%
REM for %%A in (%_args%) do (
REM if /i "%%A"=="-wow" (set _rel1=1) else if /i "%%A"=="-arm" (set _rel2=1) else if /i "%%A"=="-su" (set _elv=1)
REM )
REM :NoProgArgs
REM set "_cmdf=%~f0"
REM if exist "%SystemRoot%\Sysnative\cmd.exe" if not defined _rel1 (
REM setlocal EnableDelayedExpansion
REM start %SystemRoot%\Sysnative\cmd.exe /c ""!_cmdf!" -wow %*"
REM exit /b
REM )
REM if exist "%SystemRoot%\SysArm32\cmd.exe" if /i %PROCESSOR_ARCHITECTURE%==AMD64 if not defined _rel2 (
REM setlocal EnableDelayedExpansion
REM start %SystemRoot%\SysArm32\cmd.exe /c ""!_cmdf!" -arm %*"
REM exit /b
REM )
REM set "SysPath=%SystemRoot%\System32"
REM set "Path=%SystemRoot%\System32;%SystemRoot%\System32\Wbem;%SystemRoot%\System32\WindowsPowerShell\v1.0\"
REM if exist "%SystemRoot%\Sysnative\reg.exe" (
REM set "SysPath=%SystemRoot%\Sysnative"
REM set "Path=%SystemRoot%\Sysnative;%SystemRoot%\Sysnative\Wbem;%SystemRoot%\Sysnative\WindowsPowerShell\v1.0\;%Path%"
REM )
REM set "_err===== ERROR ===="
REM set "_wrn===== WARNING ===="
REM set "_WUA=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update"
REM set "xOS=64"
REM set "_PT1o= 40 00 00 00 00 00 00 00 00 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 04 00 00 00 00 00 00 00 7E 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 04 00 00 00 00 00 00 00 7F 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 04 00 00 00 00 00 00 00"
REM set "_PT1m= 40 00 00 00 00 00 00 00 00 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 00 00 00 00 00 00 00 7E 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 00 00 00 00 00 00 00 7F 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 04 00 00 00 00 00 00 00"
REM set "_PT2o= 0B 00 00 00 00 00 00 00 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 00 00 00 00 00 00 00 0B 00 00 00 00 00 00 00 00 05 00 00 00 00 00 00 00 00 00 00 00 00 00 00 04 00 00 00 00 00 00 00 18 00 00 00 00 00 00 00 00 00 02 00 00 00 00 00 00 00 00 00 00 00 00 00 03 00 00 00 00 00 00 00"
REM set "_PT2m= 0B 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03 00 00 00 00 00 00 00 0B 00 00 00 00 00 00 00 00 05 00 00 00 00 00 00 00 00 00 00 00 00 00 00 04 00 00 00 00 00 00 00 18 00 00 00 00 00 00 00 00 00 04 00 00 00 00 00 00 00 00 00 00 00 00 00 03 00 00 00 00 00 00 00"
REM if /i %PROCESSOR_ARCHITECTURE%==x86 (if not defined PROCESSOR_ARCHITEW6432 (
REM set "xOS=32"
REM set "_PT1o= 40 00 00 00 00 80 00 00 00 00 00 00 04 00 00 00 7E 00 00 00 01 00 00 00 00 00 00 00 04 00 00 00 7F 00 00 00 01 00 00 00 00 00 00 00 04 00 00 00"
REM set "_PT1m= 40 00 00 00 00 20 00 00 00 00 00 00 03 00 00 00 7E 00 00 00 01 00 00 00 00 00 00 00 03 00 00 00 7F 00 00 00 01 00 00 00 00 00 00 00 04 00 00 00"
REM set "_PT2o= 0B 00 00 00 80 00 00 00 00 00 00 00 03 00 00 00 0B 00 00 00 00 05 00 00 00 00 00 00 04 00 00 00 18 00 00 00 00 00 02 00 00 00 00 00 03 00 00 00"
REM set "_PT2m= 0B 00 00 00 00 01 00 00 00 00 00 00 03 00 00 00 0B 00 00 00 00 05 00 00 00 00 00 00 04 00 00 00 18 00 00 00 00 00 04 00 00 00 00 00 03 00 00 00"
  REM )
REM )
REM set "_PT1o=%_PT1o: =\x%"
REM set "_PT1m=%_PT1m: =\x%"
REM set "_PT2o=%_PT2o: =\x%"
REM set "_PT2m=%_PT2m: =\x%"
REM for /f "tokens=6 delims=[]. " %%# in ('ver') do (
REM if %%# gtr 6100 goto :E_Win
REM if %%# lss 6002 goto :E_Win
REM )
REM reg query HKU\S-1-5-19 1>nul 2>nul || goto :E_Admin

REM set "_bat=%~f0"
REM set "_work=%~dp0"
REM set "_work=%_work:~0,-1%"
REM setlocal EnableDelayedExpansion
REM ::pushd "!_work!"
REM if not exist "%xOS%\" (
REM echo %_err%
REM echo Required folder %xOS% is missing.
REM goto :TheEnd
REM )
REM cd %xOS%\
REM for %%# in (
REM bbe.exe
REM ) do if not exist "%%~#" (
REM echo %_err%
REM echo Required file %xOS%\%%~nx# is missing.
REM goto :TheEnd
REM )

REM :Begin
REM if not exist "%SysPath%\wuaueng6.dll" if not exist "%SysPath%\wuaueng3.dll" (
REM echo %_err%
REM echo Patched WUC is not detected.
REM echo run Patch_WUC.cmd or BypassESU first.
REM goto :TheEnd
REM )
REM set _wufile=wuaueng6.dll
REM if exist "%SysPath%\wuaueng3.dll" set _wufile=wuaueng3.dll
REM set _wuname=%_wufile:~0,-4%.wuc

REM :MainMenu
REM set _elr=0
REM @cls
REM echo ____________________________________________________________
REM echo.
REM echo [1] Apply DataStore.edb fix
REM echo.
REM echo [2] Restore DataStore.edb defaults
REM echo.
REM echo [9] Exit
REM echo.
REM echo ____________________________________________________________
REM echo.
REM ::choice /C 129 /N /M "Choose a menu option: "
REM set _elr=%errorlevel%
REM ::if %_elr%==3 goto :eof
REM ::if %_elr%==2 goto :ESEundo
REM ::if %_elr%==1 goto :ESEfix
REM ::goto :MainMenu

REM :ESEfix
REM @cls
REM if exist "%SysPath%\%_wuname%" (
REM echo %_wrn%
REM echo %_wuname% file is detected.
REM ::echo use option [2] to restore it, or delete it manually first
REM echo Proceeding with Windows Update
REM goto :TheEnd
REM )
REM echo.
REM echo ____________________________________________________________
REM echo.
REM echo Applying fix . . .

REM ::XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
REM echo DataStore Patched>>"%~dp0log.txt"
REM echo RESTART>"%~dp0RESTART.txt"
REM ::XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

REM call :sharedB
REM echo.
REM echo patch %_wufile% . . .
REM ren %SysPath%\%_wufile% %_wuname%
REM 1>nul 2>nul bbe.exe -e "s/%_PT1o%/%_PT1m%/" -e "s/%_PT2o%/%_PT2m%/" -o %SysPath%\%_wufile% %SysPath%\%_wuname%
REM if not exist "%SysPath%\%_wufile%" (
REM echo.
REM echo %_err%
REM echo Failed.
REM echo restoring original file . . .
REM ren %SysPath%\%_wuname% %_wufile%
REM )
REM call :sharedE
REM echo.
REM echo Done.
REM goto :TheEnd

REM :sharedB
REM echo.
REM echo set manual AUOptions {0x1}
REM set "_ebak=0x1"
REM for /f "skip=2 tokens=2*" %%a in ('reg query "%_WUA%" /v AUOptions 2^>nul') do set "_ebak=%%b"
REM reg query "%_WUA%" /v AUOptions_bak 1>nul 2>nul && for /f "skip=2 tokens=2*" %%a in ('reg query "%_WUA%" /v AUOptions_bak 2^>nul') do set "_ebak=%%b"
REM 1>nul 2>nul reg add "%_WUA%" /f /v AUOptions /t REG_DWORD /d 0x1
REM 1>nul 2>nul reg add "%_WUA%" /f /v AUOptions_bak /t REG_DWORD /d %_ebak%
REM echo.
REM echo stop WU services
REM call :StopService BITS 1>nul 2>nul
REM call :StopService TrustedInstaller 1>nul 2>nul
REM call :StopService wuauserv 1>nul 2>nul
REM echo.
REM echo remove DataStore.edb and Logs
REM del f /q %SystemRoot%\SoftwareDistribution\DataStore\DataStore.edb 1>nul 2>nul
REM pushd %SystemRoot%\SoftwareDistribution\DataStore\Logs
REM rmdir /s /q . 1>nul 2>nul
REM popd
REM exit /b

REM :sharedE
REM echo.
REM echo set original AUOptions {%_ebak%}
REM 1>nul 2>nul reg add "%_WUA%" /f /v AUOptions /t REG_DWORD /d %_ebak%
REM 1>nul 2>nul reg delete "%_WUA%" /f /v AUOptions_bak
REM echo.
REM echo restart WU service
REM call :StartService wuauserv 1>nul 2>nul
REM exit /b

REM :ESEundo
REM echo.
REM echo ____________________________________________________________
REM echo.
REM echo Restoring defaults . . .
REM call :sharedB
REM if exist "%SysPath%\%_wuname%" (
REM echo.
REM echo rename %_wuname% to %_wufile% . . .
REM if exist "%SysPath%\%_wufile%" del /f /q %SysPath%\%_wufile%
REM ren %SysPath%\%_wuname% %_wufile%
REM ) else (
REM echo.
REM echo revert patched %_wufile% . . .
REM ren %SysPath%\%_wufile% %_wuname%
REM 1>nul 2>nul bbe.exe -e "s/%_PT1m%/%_PT1o%/" -e "s/%_PT2m%/%_PT2o%/" -o %SysPath%\%_wufile% %SysPath%\%_wuname%
REM if exist "%SysPath%\%_wufile%" (if exist "%SysPath%\%_wuname%" del /f /q %SysPath%\%_wuname%) else (ren %SysPath%\%_wuname% %_wufile%)
REM )
REM call :sharedE
REM echo.
REM echo Done.
REM goto :TheEnd

REM :StopService
REM sc query %1 | find /i "STOPPED" || net stop %1 /y
REM sc query %1 | find /i "STOPPED" || sc stop %1
REM exit /b

REM :StartService
REM sc query %1 | find /i "STOPPED" && net start %1 /y
REM sc query %1 | find /i "STOPPED" && sc start %1
REM exit /b

REM :E_Admin
REM echo %_err%
REM echo This script requires administrator privileges.
REM goto :TheEnd

REM :E_Win
REM echo %_err%
REM echo This project is for Windows Vista / Server 2008 only.
REM goto :TheEnd

REM :TheEnd
REM echo.
REM ::echo Press any key to exit.
REM ::pause >nul
REM ::goto :eof

REM popd

reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v AUOptions | find "0x2" > nul 2>&1
if errorlevel 1 (
	echo Windows Update will be set to check but let me choose
	Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" /v AUOptions /t REG_DWORD /d "2" /f 1>nul
	echo WUOptions Set to 2^ >>"%~dp0log.txt"
	echo restart>"%~dp0RESTART.txt"
)

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v WUServer | find "legacyupdate" > nul 2>&1
if errorlevel 1 (
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v WUServer /t REG_SZ /d "https://legacyupdate.net/v6" /f
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v WUStatusServer /t REG_SZ /d "https://legacyupdate.net/v6" /f
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v UseWUServer /t REG_DWORD /d "dword:00000001" /f
	echo LegacyUpdateSet>>"%~dp0log.txt"
	echo restart>"%~dp0RESTART.txt"
)

echo DONE>"%~dp0WAVE6.txt"
if exist "%~dp0RESTART.txt" (goto :RESTART)

::XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

:WAVE7

:WUPDATE
echo ===============================================================================
echo Finnished installing updates. The Windows Update is set to LegacyUpdate.
echo Scanning for updates...
echo ===============================================================================

wuauclt /detectnow
echo InitialScan>>"%~dp0log.txt"

for %%f in (1 2 3 4 5 6) do (
	if exist "%~dp0WAVE%%f.txt" del "%~dp0WAVE%%f.txt"
)

pause

goto :EOF

::==================================================================================
::==================================================================================
::==================================================================================

:RESTART
if "%arch%" == "x64" (
	reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\RunOnce" /v RunItOnce /t REG_SZ /d %0 /f 1>nul
) else (
	reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" /v RunItOnce /t REG_SZ /d %0 /f 1>nul
)

if exist "%~dp0RESTART.txt" (del "%~dp0RESTART.txt")
echo.
echo The computer will restart in %shutdown_timer% seconds
echo RESTART>>"%~dp0log.txt"
shutdown.exe /%shutdown_mode% /t %shutdown_timer%

:PING
echo Closing in %ping_timer% Seconds... && (echo.) && (ping 127.0.0.1 -n %ping_timer% >nul)