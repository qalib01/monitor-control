@echo off
setlocal EnableDelayedExpansion

set IP_LINK_MAP_FILE=ip_link_map.txt
set ADB_PATH=adb.exe

set ACTION=%1
set TARGET_DEVICES=%2

if "%ACTION%"=="" goto usage

REM --- DEVICE LIST HAZIRLANMASI ---
set DEVICES=

if not "%TARGET_DEVICES%"=="" (
    :: Vergülləri boşluğa çeviririk ki, Batch dövrü (loop) işləyə bilsin
    set DEVICES=%TARGET_DEVICES:,= %
) else (
    :: Fayldan yalnız İP-ləri (ilk sütun) oxuyub bir sətrə yığırıq
    for /f "tokens=1" %%A in ('findstr /v "^#" %IP_LINK_MAP_FILE%') do (
        set DEVICES=!DEVICES! %%A
    )
)

REM --- ACTIONS ---
if "%ACTION%"=="power-on" goto power-on
if "%ACTION%"=="power-off" goto power-off
if "%ACTION%"=="home" goto home
if "%ACTION%"=="redirect" goto redirect
if "%ACTION%"=="sequence" goto sequence

goto usage

:power-on
echo --- Agilli Yandirma Baslayir ---
for %%D in (%DEVICES%) do (
    set DEVICE_IP=%%D
    echo.
    echo Processing: !DEVICE_IP!
    echo ----------------------------------------
    %ADB_PATH% connect !DEVICE_IP! >nul 2>&1
    timeout /t 2 /nobreak >nul

    :: Status yoxla
    %ADB_PATH% -s !DEVICE_IP! shell "dumpsys power" | findstr /i "mWakefulness=Awake Display.Power:.state=ON" >nul
    if errorlevel 1 (
        echo Status: OFF. Sending Power ON...
        %ADB_PATH% -s !DEVICE_IP! shell "input keyevent 26"
    ) else (
        echo Status: ALREADY ON. Skipping.
    )
    %ADB_PATH% disconnect !DEVICE_IP! >nul 2>&1
)
echo --- Agilli Yandirma Bitdi ---
goto end

:power-off
echo --- Agilli Sondurme Baslayir ---
for %%D in (%DEVICES%) do (
    set DEVICE_IP=%%D
    echo.
    echo Processing: !DEVICE_IP!
    echo ----------------------------------------
    %ADB_PATH% connect !DEVICE_IP! >nul 2>&1
    timeout /t 1 /nobreak >nul

    :: Status yoxla
    %ADB_PATH% -s !DEVICE_IP! shell "dumpsys power" | findstr /i "mWakefulness=Awake Display.Power:.state=ON" >nul
    if errorlevel 1 (
        echo Status: ALREADY OFF. Skipping.
    ) else (
        echo Status: ON. Sending Power OFF...
        %ADB_PATH% -s !DEVICE_IP! shell "input keyevent 26"
    )
    %ADB_PATH% disconnect !DEVICE_IP! >nul 2>&1
)
echo --- Agilli Sondurme Bitdi ---
goto end

:home
echo --- Home yonlendirme baslayir ---
for %%D in (%DEVICES%) do (
    echo %%D home yonlendirilir
    %ADB_PATH% connect %%D >nul 2>&1
    %ADB_PATH% -s %%D shell input keyevent 3
    %ADB_PATH% disconnect %%D >nul 2>&1
)
echo --- Home yonlendirme bitdi ---
goto end

:redirect
echo --- Linke yonlendirme baslayir ---
for %%D in (%DEVICES%) do (
    :: Fayldan həmin İP-yə uyğun URL-i tapırıq
    for /f "tokens=2" %%U in ('findstr /b "%%D" %IP_LINK_MAP_FILE%') do (
        echo %%D cihazi %%U linkine yonlendirilir
        %ADB_PATH% connect %%D >nul 2>&1
        %ADB_PATH% -s %%D shell am start -a android.intent.action.VIEW -d "%%U"
        %ADB_PATH% disconnect %%D >nul 2>&1
    )
)
echo --- Linke yonlendirme bitdi ---
goto end

:sequence
echo --- Agilli Idareetme Baslayir ---
for %%D in (%DEVICES%) do (
    echo %%D cihaza baglanir...
    %ADB_PATH% connect %%D >nul 2>&1
    
    :: 1. Yoxla və Yandır (Smart Power On)
    %ADB_PATH% -s %%D shell "dumpsys power" | findstr /i "mWakefulness=Awake Display.Power:.state=ON" >nul
    if errorlevel 1 (
        echo %%D cihaz yandirilir...
        %ADB_PATH% -s %%D shell input keyevent 26
        timeout /t 3 /nobreak >nul
    )

    :: 2. Redirect
    for /f "tokens=2" %%U in ('findstr /b "%%D" %IP_LINK_MAP_FILE%') do (
        echo %%D cihazi %%U linkine yonlendirilir
        %ADB_PATH% -s %%D shell am start -a android.intent.action.VIEW -d "%%U"
    )
    
    timeout /t 2 /nobreak >nul
    %ADB_PATH% disconnect %%D >nul 2>&1
)
echo --- Agilli Idareetme Bitdi ---
goto end

:usage
echo Istifadə:
echo    %0 power-on [IP,IP]
echo    %0 power-off [IP,IP]
echo    %0 home [IP,IP]
echo    %0 redirect [IP,IP]
echo    %0 sequence [IP,IP]
echo.
echo Numune: %0 power-on 192.168.1.10,192.168.1.11
goto end

:end
endlocal