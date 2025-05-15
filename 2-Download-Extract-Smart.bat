@echo off

:: '0' == false, Only missing updates for your architecture will be downloaded, '1' == true, Will download everything
set "backup=0"
set ping_timer=3
set "arch=x86"
set "bit=32"
if exist "%WinDir%\SysWOW64" (
	set "arch=x64"
	set "bit=64"
)

set "wget_path=%~dp0000-wget\%arch%"
if not exist "%wget_path%" (
	mkdir "%wget_path%"
)

:WGET
if not exist "%wget_path%\wget.exe" (
	cls

	echo ===============================================================================
	echo Firefox is needed to open wget's download link.
	echo The link will open after you click any key.
	echo Install it and set it as default.
	echo ===============================================================================
	call :SHORTCUT "%~dp0Firefox-52.9.0esr-sha1-download.url" "https://archive.mozilla.org/pub/firefox/releases/52.9.0esr/win32-sha1/en-US/Firefox Setup 52.9.0esr.exe"
	pause
	"%~dp0Firefox-52.9.0esr-sha1-download.url" && del "%~dp0Firefox-52.9.0esr-sha1-download.url"
	pause
	echo.

	echo ===============================================================================
	echo Download wget.exe and placed it in:
	echo %wget_path%\wget.exe
	echo ===============================================================================
	@REM call :SHORTCUT "%wget_path%\wget-%arch%-Download.url" "https://eternallybored.org/misc/wget/1.21.3/%bit%/wget.exe"
	call :SHORTCUT "%wget_path%\wget.url" "https://eternallybored.org/misc/wget/1.21.4/%bit%/wget.exe"
	pause
	"%wget_path%\wget.url" && del "%wget_path%\wget.url"
	pause
	echo.
	
	if exist "%wget_path%\wget.exe" (
		echo wget.exe is succesfully placed where it should, proceeding...
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
if %backup% == 0 ( echo ========================= Download mode: smart ================================)
if %backup% == 1 ( echo ========================= Download mode: backup ===============================)
echo ===============================================================================
ping 127.0.0.1 -n %ping_timer% > nul

:DOWNLOADER
for /d %%a in (*) do (
	pushd "%~dp0%%a"
	if exist "%~dp0%%a\filelist.txt" (
		for /f "eol=; tokens=1,2*" %%i in (filelist.txt) do (
			if not exist "%~dp0%%a\%%i" (
				if %backup% == 1 (
					"%~dp0000-wget\%arch%\wget.exe" -q --show-progress --no-hsts --no-check-certificate -O "%%i" "%%j"
				)
				if %backup% == 0 (
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

@REM for /f %%i in ("%~dp0001-Tools\DirectX-Repack*.zip") do (
@REM 	if not exist "%~dp0211-Repacks\DirectX_Redist_Repack_x86_x64.exe" (
@REM 		echo Extracting DirectX_Repack
@REM 		"%programfiles%\7-Zip\7z.exe" x "%~dp0001-Tools\DirectX-Repack*.zip" -o"%~dp0211-Repacks\" -aoa > nul
@REM 		ping 127.0.0.1 -n %ping_timer% > nul
@REM 	)
@REM )
if exist "%~dp0001-Tools\DirectX-Repack*.zip" (
	if not exist "%~dp0211-Repacks\DirectX_Redist_Repack_x86_x64.exe" (
		echo Extracting DirectX_Repack
		"%programfiles%\7-Zip\7z.exe" x "%~dp0001-Tools\DirectX-Repack*.zip" -o"%~dp0211-Repacks\" -aoa > nul
		ping 127.0.0.1 -n %ping_timer% > nul
	)
)

if exist "%~dp0001-Tools\dotNetFx35-Repack*.zip" (
	if not exist "%~dp0211-Repacks\dotNetFx35_x86_x64.exe" (
		echo Extracting dotNetFx35 repack
		ping 127.0.0.1 -n %ping_timer% > nul
		"%programfiles%\7-Zip\7z.exe" x "%~dp0001-Tools\dotNetFx35-Repack*.zip" -o"%~dp0211-Repacks\" -aoa > nul
	)
)

if exist "%~dp0001-Tools\NDP462-Repack-x86-x64-ENU*.zip" (
	if not exist "%~dp0211-Repacks\NDP462-x86-x64-ENU.exe" (
		echo Extracting NDP462-x86-x64-ENU
		"%programfiles%\7-Zip\7z.exe" x "%~dp0001-Tools\NDP462-Repack-x86-x64-ENU*.zip" -o"%~dp0211-Repacks\" -aoa > nul
		ping 127.0.0.1 -n %ping_timer% > nul
	)
)

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

REM example FETCH call usage
call :FETCH %%i %%j
:FETCH
"%~dp0000-wget\%arch%\wget.exe" -q --show-progress --no-hsts --no-check-certificate -O "%1" "%2"
exit /b

REM example SHORTCUT call usage
call :SHORTCUT link.txt www.google.com
:SHORTCUT
echo [{000214A0-0000-0000-C000-000000000046}]>>"%1"
echo Prop3=19,11>>"%1"
echo [InternetShortcut]>>"%1"
echo URL=%2>>"%1"
echo IDList=>>"%1"
exit /b