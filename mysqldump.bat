rem -- mysqldump
rem -- 2018/11/07 Jwu
@ECHO OFF

rem -- MySQL export settings
SET dbName=your_db_name
SET dbUser=dump_name
SET dbPass=dump_pass

rem -- Backup settings
SET backupDir=D:\your_dir\backup\

set zipPath=C:\Program Files\7-Zip\7z.exe
SET mysqldumpPath=C:\php\mysql\bin\mysqldump.exe


rem -- No change is required
set zipPrm=a -t7z -mx9 -sdel
SET schemeSaveName=scheme_%dbName%.sql
SET additionalSaveName=additional_%dbName%.sql
SET dataSaveName=data_%dbName%.sql
SET schemeSavePath=%backupDir%%schemeSaveName%
SET additionalSavePath=%backupDir%%additionalSaveName%
SET dataSavePath=%backupDir%%dataSaveName%

for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"

set "fullstamp=%YYYY%-%MM%-%DD%_%HH%%Min%%Sec%"

SET dataZipName=%fullstamp%_%dbName%.zip
SET dataZipPath=%backupDir%%dataZipName%

if NOT exist "%backupDir%" mkdir "%backupDir%"

chcp 65001
@echo MySQL - Database Import - Recovery Methods> howToUse.txt
@echo Database: %dbName%>> howToUse.txt
@echo mysql -u [userName] -p[passWord] %dbName% --default-character-set=utf8 ^< %schemeSaveName%>> howToUse.txt
@echo mysql -u [userName] -p[passWord] %dbName% --default-character-set=utf8 ^< %additionalSaveName%>> howToUse.txt
@echo mysql -u [userName] -p[passWord] %dbName% --default-character-set=utf8 ^< %dataSaveName%>> howToUse.txt

rem -- Mysqldump
rem -- (structure only)
"%mysqldumpPath%" --no-data --skip-events --skip-routines --skip-triggers -u%dbUser% -p%dbPass% %dbName% > "%schemeSavePath%"
rem -- ONLY the stored procedures and triggers 
"%mysqldumpPath%" --no-data --events --routines --triggers --no-create-info --no-create-db --skip-opt -u%dbUser% -p%dbPass% %dbName% > "%additionalSavePath%"
rem -- (data only) --insert-ignore
"%mysqldumpPath%" --lock-all-tables --skip-extended-insert --skip-events --skip-routines --skip-triggers --force -u%dbUser% -p%dbPass% %dbName% > "%dataSavePath%"

rem --  Delay time
@ping 127.0.0.1 -n 1 -w 2500 > nul

call "%zipPath%" %zipPrm% "%dataZipPath%" "%dataSavePath%" "%schemeSavePath%" "%additionalSavePath%" howToUse.txt

cd /D %~dp0
echo %~dp0

:exit
pause
