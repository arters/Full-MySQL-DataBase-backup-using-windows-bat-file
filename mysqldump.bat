rem --mysqldump
rem 2018/11/07 Jwu
@ECHO OFF

REM 取得今天的年、月、日 (補零)
SET TodayYear=%date:~0,4%
SET TodayMonthP0=%date:~5,2%
SET TodayDayP0=%date:~8,2%

REM 修正 Batch 遇到 08, 09 會視為八進位的問題
IF %TodayMonthP0:~0,1% == 0 (
	SET /A TodayMonth=%TodayMonthP0:~1,1%+0
) ELSE (
	SET /A TodayMonth=TodayMonthP0+0
)
IF %TodayMonthP0:~0,1% == 0 (
	SET /A TodayDay=%TodayDayP0:~1,1%+0
) ELSE (
	SET /A TodayDay=TodayDayP0+0
)

set hour=%time:~0,2%
if "%hour:~0,1%" == " " set hour=0%hour:~1,1%
set min=%time:~3,2%
if "%min:~0,1%" == " " set min=0%min:~1,1%
set secs=%time:~6,2%
if "%secs:~0,1%" == " " set secs=0%secs:~1,1%

rem -- 儲存路徑
SET DevComputerName=ComputerName

rem -- 偵測是否為測試環境
if %ComputerName% == %DevComputerName% (
rem -- 測試環境
    set exe7z=C:\Program Files\7-Zip\7z.exe
    SET mysqldumpPath=C:\php\mysql\bin\mysqldump.exe
    SET dbName=your_db
    SET mysqlUserName=dumpname
    SET mysqlPassword=dumppass
    rem -- 備份路徑
    SET backupDir=D:\backup\db\
) ELSE (
rem -- 正式環境
    set exe7z=C:\Program Files\7-Zip\7z.exe
    SET mysqldumpPath=C:\php\mysql\bin\mysqldump.exe
    SET dbName=your_db
    SET mysqlUserName=dumpname
    SET mysqlPassword=dumppass
    rem -- 備份路徑
    SET backupDir=D:\backup\db\
)
rem -- 7z參數
rem -- -sdel (Delete files after compression) switch
rem -- -mx0 (0/1/3/5/7/9, 壓縮率, 預設為5, 數字愈大壓縮率愈高, 0為不壓縮)
set zipPrm=a -t7z -mx9 -sdel

rem -- 輸出路徑
SET saveDir=%~dp0\storage\
rem -- data_%TodayYear%%TodayMonthP0%%TodayDayP0%_%hour%%min%%secs%_%dbName%.sql
SET schemeSaveName=scheme_%dbName%.sql
SET additionalSaveName=additional_%dbName%.sql
SET dataSaveName=data_%dbName%.sql

SET schemeSavePath=%saveDir%%schemeSaveName%
SET additionalSavePath=%saveDir%%additionalSaveName%
SET dataSavePath=%saveDir%%dataSaveName%

SET dataZipName=%TodayYear%%TodayMonthP0%%TodayDayP0%_%hour%%min%%secs%_%dbName%.zip
SET dataZipPath=%saveDir%%dataZipName%

SET helpName=%saveDir%howToUse.txt

rem -- 創建目錄
if NOT exist "%saveDir%" mkdir "%saveDir%"
if NOT exist "%backupDir%" mkdir "%backupDir%"

chcp 65001
@echo MySQL匯入資料(import)> %helpName%
@echo 資料庫：%dbName% >> %helpName%
@echo mysql -u [userName] -p[passWord] %dbName% --default-character-set=utf8 ^< %schemeSaveName%>> %helpName%
@echo mysql -u [userName] -p[passWord] %dbName% --default-character-set=utf8 ^< %additionalSaveName%>> %helpName%
@echo mysql -u [userName] -p[passWord] %dbName% --default-character-set=utf8 ^< %dataSaveName%>> %helpName%

rem -- mysqldump
rem -- (structure only)
"%mysqldumpPath%" --no-data --skip-events --skip-routines --skip-triggers -u%mysqlUserName% -p%mysqlPassword% %dbName% > %schemeSavePath%
rem -- ONLY the stored procedures and triggers 
"%mysqldumpPath%" --no-data --events --routines --triggers --no-create-info --no-create-db --skip-opt -u%mysqlUserName% -p%mysqlPassword% %dbName% > %additionalSavePath%
rem -- (data only) --insert-ignore
"%mysqldumpPath%" --lock-all-tables --skip-extended-insert --skip-events --skip-routines --skip-triggers --force -u%mysqlUserName% -p%mysqlPassword% %dbName% > %dataSavePath%

rem -- 暫時停止1秒
@ping 127.0.0.1 -n 1 -w 1000 > nul

rem -- call "%exe7z%" %zipPrm% %dataZipPath% %dataSavePath%
call "%exe7z%" %zipPrm% %dataZipPath% %dataSavePath% %schemeSavePath% %additionalSavePath% %helpName%

if exist "%backupDir%" (
    rem -- 切換到backup目錄
    cd /D %backupDir%
    copy %dataZipPath% %backupDir%%dataZipName%
)

rem -- 移動回原始bat目錄
cd /D %~dp0
echo %~dp0

:exit
pause
