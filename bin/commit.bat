@echo off
setlocal EnableExtensions DisableDelayedExpansion

set /A PROJECT=538168443
set unzip="%PROGRAMFILES%\7-zip\7z.exe"

@echo Clearing files and folders from previous execution

call :GetDownloadFolder

del "%DOWNLOAD%\%PROJECT%.zip" 1> nul

call :clean scripts
call :clean sb3
call :clean assets

@echo Parsing project at rokcoder.com/sb3-to-txt

start "" "http://www.rokcoder.com/sb3-to-txt?projectId=%PROJECT%&autosave"

:wait
if exist "%DOWNLOAD%\%PROJECT%.zip" goto ready
timeout 1 /nobreak > nul
goto wait

:ready
%unzip% x -o%~dp0.. -bso0 -bd %DOWNLOAD%\%PROJECT%.zip

cd %~dp0..\assets\
%unzip% x -o. -bso0 -bse0 -bd %~dp0..\sb3\%PROJECT%.sb3 *.mp3 *.wav *.png *.jpg *.svg *.bmp *.jpeg *.gif

@echo Relocating parsed scripts and assets to correct folders

for /F "usebackq delims=" %%a in ("assetFolders.txt") do mkdir %%a 1> nul 2> nul
for /F "usebackq delims=" %%a in ("assoc.txt") do move %%a 1> nul 2> nul

del assocFolders.txt 1> nul 2> nul
del assoc.txt 1> nul 2> nul

github %~dp0..

exit /b

:clean
if exist %~dp0..\%1 rmdir /S /Q %~dp0..\%1
mkdir %~dp0..\%1
exit /b

:GetDownloadFolder
set "Reg32=%SystemRoot%\System32\reg.exe"
if not "%ProgramFiles(x86)%" == "" set "Reg32=%SystemRoot%\SysWOW64\reg.exe"
set "DOWNLOAD="
for /F "skip=1 tokens=1,2*" %%T in ('%Reg32% query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "{374DE290-123F-4565-9164-39C4925E467B}" 2^>nul') do (
    if /I "%%T" == "{374DE290-123F-4565-9164-39C4925E467B}" (
        set "DOWNLOAD=%%V"
        exit /b
    )
)
exit /b
