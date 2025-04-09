::--------------------------------------------------------------------------------------
mkdir 001-Tools

echo ;7zip-2301-x86.exe https://www.7-zip.org/a/7z2301.exe>>001-Tools\filelist.txt
echo ;7zip-2301-x64.exe https://www.7-zip.org/a/7z2301-x64.exe>>001-Tools\filelist.txt
echo 7zip-2408-x86-20240811.exe https://www.7-zip.org/a/7z2408.exe>>001-Tools\filelist.txt
echo 7zip-2408-x64-20240811.exe https://www.7-zip.org/a/7z2408-x64.exe>>001-Tools\filelist.txt

echo 406-Vista_SHA2_WUC-x86-x64.7z https://gitlab.com/stdout12/adns/uploads/9cc412e91502ca6ce8d1d9fad10b27d6/Vista_SHA2_WUC.7z>>001-Tools\filelist.txt
echo 407-BypassESU_v7_WS2008-x86-x64-(pass=2023).7z https://gitlab.com/stdout12/adns/uploads/fdc7ef68584c12bf09b2358a8b807b66/BypassESU-v7-WS2008.7z>>001-Tools\filelist.txt
echo 408-WU_DataStore_Fix-x86-x64.zip https://gitlab.com/stdout12/adns/uploads/e4a9c447ae15f7eb8fc42d8e8db54879/WU_DataStore_Fix.zip>>001-Tools\filelist.txt
echo 410-WMF30_KB2506146_Vista_Installer-x86-x64.7z https://gitlab.com/stdout12/adns/uploads/caed19915206e9b2cb6dde377b9ed19e/WMF30-KB2506146-Vista-Installer.7z>>001-Tools\filelist.txt

::--------------------------------------------------------------------------------------
mkdir 101-Important-Updates

echo windows6.0-kb3205638-x64-Security-Update-Graphics-Components-[LongScan].msu https://catalog.s.download.windowsupdate.com/d/msdownload/update/software/secu/2016/11/windows6.0-kb3205638-x64_a52aaa009ee56ca941e21a6009c00bc4c88cbb7c.msu>>101-Important-Updates\filelist.txt
echo windows6.0-kb3205638-x86-Security-Update-Graphics-Components-[LongScan].msu https://catalog.s.download.windowsupdate.com/d/msdownload/update/software/secu/2016/11/windows6.0-kb3205638-x86_e2211e9a6523061972decd158980301fc4c32a47.msu>>101-Important-Updates\filelist.txt

echo windows6.0-kb4012583-x64-Security-Update-Graphics-Components-[LongScan].msu https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/secu/2017/02/windows6.0-kb4012583-x64_f63c9a85aa877d86c886e432560fdcfad53b752d.msu>>101-Important-Updates\filelist.txt
echo windows6.0-kb4012583-x86-Security-Update-Graphics-Components-[LongScan].msu https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/secu/2017/02/windows6.0-kb4012583-x86_1887cb5393b62cbd2dbb6a6ff6b136e809a2fbd0.msu>>101-Important-Updates\filelist.txt

echo windows6.0-kb4015380-x64-Security-Update-ATMFD.dll-(Replaced-by-KB4534303)-[LongScan].msu https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/secu/2017/03/windows6.0-kb4015380-x64_959aedbe0403d160be89f4dac057e2a0cd0c6d40.msu>>101-Important-Updates\filelist.txt
echo windows6.0-kb4015380-x86-Security-Update-ATMFD.dll-(Replaced-by-KB4534303)-[LongScan].msu https://catalog.s.download.windowsupdate.com/d/msdownload/update/software/secu/2017/03/windows6.0-kb4015380-x86_3f3548db24cf61d6f47d2365c298d739e6cb069a.msu>>101-Important-Updates\filelist.txt

echo windows6.0-kb4019204-x64-Security-Update-win32k-Information-Disclosure-(Replaced-by-KB4534303)-[LongScan].msu https://catalog.s.download.windowsupdate.com/c/csa/csa/secu/2017/05/windows6.0-kb4019204-x64-custom_d9d9d6baa3ea706ff7148ca2c0a06f861c1d77c4.msu>>101-Important-Updates\filelist.txt
echo windows6.0-kb4019204-x86-Security-Update-win32k-Information-Disclosure-(Replaced-by-KB4534303)-[LongScan].msu https://catalog.s.download.windowsupdate.com/c/csa/csa/secu/2017/05/windows6.0-kb4019204-x86-custom_cc1a90841c15759e36c5095580dfb0b32b34eb8a.msu>>101-Important-Updates\filelist.txt

echo windows6.0-kb4474419-v4-x64-2019-11-SHA2-Code-Signing-Support-Update-for-WS2008.msu https://catalog.s.download.windowsupdate.com/d/msdownload/update/software/secu/2019/09/windows6.0-kb4474419-v4-x64_09cb148f6ef10779d7352b7269d66a7f23019207.msu>>101-Important-Updates\filelist.txt
echo windows6.0-kb4474419-v4-x86-2019-11-SHA2-Code-Signing-Support-Update-for-WS2008.msu https://catalog.s.download.windowsupdate.com/d/msdownload/update/software/secu/2019/09/windows6.0-kb4474419-v4-x86_fd568cb47870cd8ed5ba10e1dd3c49061894030e.msu>>101-Important-Updates\filelist.txt

echo windows6.0-kb4493730-x64-2019-04-Servicing-stack-update-for-WS2008.msu https://catalog.s.download.windowsupdate.com/d/msdownload/update/software/secu/2019/04/windows6.0-kb4493730-x64_5cb91f4e9000383f061b80f88feffdf228c2443c.msu>>101-Important-Updates\filelist.txt
echo windows6.0-kb4493730-x86-2019-04-Servicing-stack-update-for-WS2008.msu https://catalog.s.download.windowsupdate.com/d/msdownload/update/software/secu/2019/04/windows6.0-kb4493730-x86_ab4368f19db796680ff445a7769886c4cdc009a0.msu>>101-Important-Updates\filelist.txt

::--------------------------------------------------------------------------------------
mkdir 202-SSU

echo ;windows6.0-kb4550737-x64-2020-04-Servicing-Stack-Update-for-WS2008.msu https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/secu/2020/04/windows6.0-kb4550737-x64_32d42377c0460b20d02ee2762265303544559967.msu>>202-SSU\filelist.txt
echo ;windows6.0-kb4550737-x86-2020-04-Servicing-Stack-Update-for-WS2008.msu https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/secu/2020/04/windows6.0-kb4550737-x86_69ff22bfa2ee7c67ba9768fe8a737272902a7212.msu>>202-SSU\filelist.txt

echo ;windows6.0-kb4575904-x64-2020-07-ESU-Preparation-Package-for-WS2008.msu https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/secu/2020/07/windows6.0-kb4575904-x64_9272724f637d85a12bfe022191c1ba56cd4bc59e.msu>>202-SSU\filelist.txt
echo ;windows6.0-kb4575904-x86-2020-07-ESU-Preparation-Package-for-WS2008.msu https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/secu/2020/07/windows6.0-kb4575904-x86_b03d9b5a886b7a8271fb0e3cd10eb5c25b79acb5.msu>>202-SSU\filelist.txt

echo ;windows6.0-kb5033466-x64-2023-12-Servicing-Stuck-Update-for-WS2008.msu https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/secu/2023/12/windows6.0-kb5033466-x64_06511d01588a683607ca8fe6a094f7bd292f6b1b.msu>>202-SSU\filelist.txt
echo ;windows6.0-kb5033466-x86-2023-12-Servicing-Stuck-Update-for-WS2008.msu https://catalog.s.download.windowsupdate.com/d/msdownload/update/software/secu/2023/12/windows6.0-kb5033466-x86_2774074289651d45077083d45f3f4b0957d741d3.msu>>202-SSU\filelist.txt

echo ;windows6.0-kb5034867-x64-2024-02-Servicing-Stack-Update-for-WS2008.msu https://catalog.s.download.windowsupdate.com/d/msdownload/update/software/secu/2024/02/windows6.0-kb5034867-x64_e63e8be2d160e9b3bc4383d897034a68e2f07173.msu>>202-SSU\filelist.txt
echo ;windows6.0-kb5034867-x86-2024-02-Servicing-Stack-Update-for-WS2008.msu https://catalog.s.download.windowsupdate.com/d/msdownload/update/software/secu/2024/02/windows6.0-kb5034867-x86_bd78faa259046a980571c5f4485d5a4a1323df33.msu>>202-SSU\filelist.txt

echo ;windows6.0-kb5039341-x64-2024-06-Servicing-Stack-Update-for-WS2008.msu https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/secu/2024/06/windows6.0-kb5039341-x64_2dfad504a6771157472ed3647d021e7b3211c505.msu>>202-SSU\filelist.txt
echo ;windows6.0-kb5039341-x86-2024-06-Servicing-Stack-Update-for-WS2008.msu https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/secu/2024/06/windows6.0-kb5039341-x86_7a86cb8540059ece4f1a420d62392446dfc8c80d.msu>>202-SSU\filelist.txt

echo ;windows6.0-kb5050682-x64-2025-01-Servicing-Stack-Update-for-WS2008.msu https://catalog.s.download.windowsupdate.com/d/msdownload/update/software/secu/2025/01/windows6.0-kb5050682-x64_22a859e66fa0ac4ec83eabe31de8ffa457194c06.msu>>202-SSU\filelist.txt
echo ;windows6.0-kb5050682-x86-2025-01-Servicing-Stack-Update-for-WS2008.msu https://catalog.s.download.windowsupdate.com/d/msdownload/update/software/secu/2025/01/windows6.0-kb5050682-x86_4c8b367acfdfa9831c4e73bb6d1e655223c5838f.msu>>202-SSU\filelist.txt

echo windows6.0-kb5056457-x64-2025-04-Servicing-Stack-Update-for-WS2008.msu https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/secu/2025/03/windows6.0-kb5056457-x64_43f36ff990974572db50a9fbd148c6c1f0b7f294.msu>>202-SSU\filelist.txt
echo windows6.0-kb5056457-x86-2025-04-Servicing-Stack-Update-for-WS2008.msu https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/secu/2025/03/windows6.0-kb5056457-x86_5459669e442b281b2a1246552c05a1032a48b117.msu>>202-SSU\filelist.txt
