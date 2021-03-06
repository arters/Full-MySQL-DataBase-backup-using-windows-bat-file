# MySQL-DataBase-backup-using-windows-bat-file

## Automatic Backup All Your MySQL Database in zip format Using Windows Batch file  

* 備份『資料』(data)、『結構』(scheme)跟 『額外語法』(triggers)
* MySQL BackUp And Recovery
* 自動定期匯出 MySQL 資料庫備份
* 可以使用 Windows 任務計劃程序自動執行此腳本
* MyISAM 或 InnoDB 支援


## Setup (設置選項)  
開啟 mysqldump.bat


Parameter | Description
------------ | -------------
dbName | 資料庫名稱
dbUser | 資料庫帳號
dbPass | 資料庫密碼
backupDir | 備份路徑
zipPath | 7z - 壓縮軟體安裝路徑
mysqldumpPath | 你的mysql安裝位置
zipPrm | 壓縮率
EXCLUDED_TABLES | 排除匯出的資料表名稱，使用逗點區隔。例如：有t1,t2,t3,t4, tn，設置t3,t4則這兩個表內資料將略過


## How to Use (使用方式)

1.將 mysqldump.bat 放置PHP專案目錄底下。
裡面有正式環境跟測試環境的參數需進行調整，
包含資料庫連線帳號密碼。

2.開啟Windows->工作排程器，設定以下，

動作：啟動程式  
程式或指令碼路徑：%your_php_folder%\mysqldump.bat  
(將%your_php_folder% 改成你的PHP專案目錄)  

備份的頻率可自行依需求調整。

## Export (匯出)
將定期輸出一包以[年月日_分秒_資料庫名稱]的壓縮檔，解開即可使用

以下將以實際資料庫名稱"my_test_db"為例，

將產生：2019-05-25_183000_my_test_db.zip(依當下日期及時間)，

內有

File name | Description
------------ | -------------
howToUse.txt | 說明如何還原匯入回原本資料庫
scheme_my_test_db.sql | 資料庫結構
data_swcb_my_test_db.sql | 匯出的資料
additional_my_test_db.sql | 外語法，如TRIGGER

## 額外安裝程式
7z - 壓縮軟體，安裝至 C:\Program Files\7-Zip\
