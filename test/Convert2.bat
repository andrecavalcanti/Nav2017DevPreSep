finsql.exe Command=ExportToNewSyntax, File="C:\Temp\TXT\fieldsecurity.txt", Database="US New", ServerName=navdevpreview1\NAVDEMO, filter="Type=table;ID=70018000..70018013", Logfile=C:\Temp\Log_ExportFile.txt

pause

txt2al --source=C:\Temp\TXT\ --target=C:\Temp\AL\ --rename --extensionStartID 70018000

pause