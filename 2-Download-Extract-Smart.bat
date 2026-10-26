@echo off

:: Uncomment if you need a full backup of the MSU files
@REM set "backup=true"
set ping_timer=3

set "arch=x86"
set "bit=32"
set "FF_REG=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\firefox.exe"
if exist "%WinDir%\SysWOW64" (
	set "arch=x64"
	set "bit=64"
	set "FF_REG=HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\App Paths\firefox.exe"
)

set "firefox_link=https://archive.mozilla.org/pub/firefox/releases/52.9.0esr/win32-sha1/en-US/Firefox Setup 52.9.0esr.exe"
set "wget_link=https://eternallybored.org/misc/wget/1.25.0/%bit%/wget.exe"

set "wget_path=%~dp0000-wget\%arch%"
if not exist "%wget_path%" (
	mkdir "%wget_path%"
)

set "FF_EXE="
for /F "skip=2 tokens=2*" %%A in ('reg query "%FF_REG%" /ve 2^>nul') do (
    set "FF_EXE=%%B"
)

:WGET
if not exist "%wget_path%\wget.exe" (
	cls

	if not defined FF_EXE (
		echo ===============================================================================
		echo Firefox is needed to open wget's download link.
		echo The link will open after you click any key.
		echo Install it and set it as default.
		echo Link: %firefox_link%
		echo ===============================================================================
		call :SHORTCUT "%~dp0Firefox-52.9.0esr-sha1-download.url" "%firefox_link%"
		pause
		"%~dp0Firefox-52.9.0esr-sha1-download.url" && del "%~dp0Firefox-52.9.0esr-sha1-download.url"
		pause
	) else (
		echo Firefox found in "%FF_EXE%"
	)
	echo.

	echo ===============================================================================
	echo Download wget.exe and placed it in:
	echo %wget_path%\wget.exe
	echo Link: %wget_link%
	echo ===============================================================================
	call :SHORTCUT "%wget_path%\wget.url" "%wget_link%"
	pause
	"%wget_path%\wget.url" && del "%wget_path%\wget.url"
	pause
	echo.
	
	if exist "%wget_path%\wget.exe" (
		echo wget.exe is successfully placed where it should, proceeding...
		echo.
		ping 127.0.0.1 -n %ping_timer% > nul
	) else (
		echo ERROR! wget.exe can't be found in:
		echo %wget_path%\wget.exe
		echo Press any key to repeat the process...
		echo.
		pause > nul
		goto :WGET
	)
)

echo ===============================================================================
if defined backup (
	echo ========================= Download mode: backup ===============================
) else (
	echo ========================= Download mode: smart ================================
)
echo ===============================================================================
ping 127.0.0.1 -n %ping_timer% > nul

:DOWNLOADER
for /d %%a in (*) do (
	pushd "%~dp0%%a"
	if exist "%~dp0%%a\filelist.txt" (
		for /f "eol=; tokens=1,2*" %%i in (filelist.txt) do (
			if not exist "%~dp0%%a\%%i" (
				if defined backup (
					"%~dp0000-wget\%arch%\wget.exe" -q --show-progress --no-hsts --no-check-certificate -O "%%i" "%%j"
				) else (
					for /f "tokens=2,3,4 delims=-" %%k in ('echo "%%i"') do (
						if not exist "%SystemRoot%\servicing\packages\package_*_for_%%k*.mum" (
							for /f "tokens=1 delims=." %%n in ('echo %%l') do (
								if "%%n" == "%arch%" (
									"%~dp0000-wget\%arch%\wget.exe" -q --show-progress --no-hsts --no-check-certificate -O "%%i" "%%j"
								) else (
									for /f "tokens=1 delims=." %%n in ('echo %%m') do (
										if "%%n" == "%arch%" (
											"%~dp0000-wget\%arch%\wget.exe" -q --show-progress --no-hsts --no-check-certificate -O "%%i" "%%j"
										)
									)
								)
							)
						)
					)
				)
			)
		)
	)
	popd
)

echo ===============================================================================
echo ========================= Downloading complete ================================
echo ===============================================================================
echo.
ping 127.0.0.1 -n %ping_timer% > nul

:7ZIP
for /f "tokens=2*" %%i in ('Reg Query "HKEY_LOCAL_MACHINE\SOFTWARE\7-Zip" /v "Path" 2^>Nul') do Set "ExePath=%%j"
if not defined ExePath (
	echo 7zip is missing, Installing...
	for %%f in ("%~dp0001-Tools\7zip-*-%arch%*.exe") do (
		%%f /S /D="%programfiles%\7-Zip"
		echo 7zip has been installed in "%programfiles%\7-Zip"
		ping 127.0.0.1 -n %ping_timer% > nul
	)
	goto :7ZIP
)


REM echo ===============================================================================
REM	echo ===================== Abbodi's Tools ==========================================
REM echo ===============================================================================

if exist "%~dp0001-Tools\406-Vista_SHA2_WUC*.7z" (
	if not exist "%~dp0406-Vista_SHA2_WUC\Install_WUC.cmd" (
		echo Extracting Vista_SHA2_WUC
		ping 127.0.0.1 -n %ping_timer% > nul
		"%programfiles%\7-Zip\7z.exe" x "%~dp0001-Tools\406-Vista_SHA2_WUC*.7z" -o"%~dp0406-Vista_SHA2_WUC" -aoa > nul
	)
) else (
	echo 406-Vista_SHA2_WUC-x86-x64.7z doesn't exist, nothing to extract
)

REM "%programfiles%\7-Zip\7z.exe" x "%~dp0001-Tools\407-BypassESU_v7_WS2008-x86-x64-(pass=2023).7z" -o"%~dp0407-BypassESU-v7-WS2008" -p2023 -aoa
REM "%programfiles%\7-Zip\7z.exe" x "%~dp0001-Tools\408-WU_DataStore_Fix*.zip" -o"%~dp0408-WU_DataStore_Fix" -aoa

REM if not exist "%~dp0410-WMF30-KB2506146-Vista-Installer" (mkdir "%~dp0410-WMF30-KB2506146-Vista-Installer")
if exist "%~dp0001-Tools\410-WMF30_KB2506146_Vista_Installer*.7z" (
	if not exist "%~dp0410-WMF30-KB2506146-Vista-Installer\1-Patch-Servicing_Stack.cmd" (
		echo Extracting 410-WMF30_KB2506146_Vista_Installer
		ping 127.0.0.1 -n %ping_timer% > nul
		"%programfiles%\7-zip\7z.exe" x "%~dp0001-Tools\410-WMF30_KB2506146_Vista_Installer*.7z" -o"%~dp0410-WMF30-KB2506146-Vista-Installer" -p2023 -aoa >nul
	)
)

REM echo ===============================================================================
REM echo ===================== Abbodi's Repacks ========================================
REM echo ===============================================================================

call :EXTRACT DirectX-Repack DirectX_Redist_Repack_x86_x64
call :EXTRACT dotNetFx35-Repack dotNetFx35_x86_x64
call :EXTRACT NDP462-Repack-x86-x64-ENU NDP462-x86-x64-ENU

echo.
echo Creating WinDefender Definition download link...
call :SHORTCUT "WinDef-Definitions-%arch%.url" "https://go.microsoft.com/fwlink/?LinkID=121721&clcid=0x409&arch=%arch%&eng=0.0.0.0&avdelta=0.0.0.0&asdelta=0.0.0.0&prod=925A3ACA-C353-458A-AC8D-A7E5EB378092"
ping 127.0.0.1 -n %ping_timer% > nul

echo.
echo Creating product red and ultimate extras URL shortcut and exiting
call :SHORTCUT "webarchive-product-red.url" "https://archive.org/details/windows-vista-product-red"
call :SHORTCUT "webarchive-ultimate-extras.url" "https://archive.org/details/windows-vista-ultimate-extras"

echo.
echo ===============================================================================
echo ======================== Everything is Complete ===============================
echo ===============================================================================
ping 127.0.0.1 -n %ping_timer% > nul

goto :EOF

REM Usage:
REM call :FETCH %%i %%j
:FETCH
"%~dp0000-wget\%arch%\wget.exe" -q --show-progress --no-hsts --no-check-certificate -O "%1" "%2"
exit /b

REM Usage:
REM call :SHORTCUT link.txt www.google.com
:SHORTCUT
echo [{000214A0-0000-0000-C000-000000000046}]>>"%1"
echo Prop3=19,11>>"%1"
echo [InternetShortcut]>>"%1"
echo URL=%2>>"%1"
echo IDList=>>"%1"
exit /b

REM Usage:
REM call :EXTRACT archive executable
:EXTRACT
if exist "%~dp0001-Tools\%1*.zip" (
	if not exist "%~dp0211-Repacks\%2.exe" (
		echo Extracting %2
		"%programfiles%\7-Zip\7z.exe" x "%~dp0001-Tools\%1*.zip" -o"%~dp0211-Repacks\" -aoa > nul
		ping 127.0.0.1 -n %ping_timer% > nul
	)
)
exit /b