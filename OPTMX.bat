@echo off
:: ================================================================
::   OPTMX v3.0 - The Ultimate Windows 11 Performance Suite
::   Visuals: UNTOUCHED  ^|  Security: KEPT  ^|  Network: MAXED
::   Auto-Admin  ^|  Runs Silently on Every Boot
:: ================================================================

:: Auto-elevate to Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting Administrator Privileges...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~s0' -Verb RunAs"
    exit
)

echo.
echo  ================================================================
echo    OPTMX v3.0 - Ultimate Performance, Privacy ^& Network Suite
echo    Visuals: UNTOUCHED  ^|  Security: ON  ^|  Network: MAXED
echo  ================================================================
echo.

:: ================================================================
:: [1/15] DEEP CACHE CLEANING
:: ================================================================
echo [1/15] Deep cleaning all caches...
del /q/f/s "%TEMP%\*" 2>nul
for /d %%i in ("%TEMP%\*") do @rd /s /q "%%i" 2>nul
del /q/f/s "%SystemRoot%\Temp\*" 2>nul
for /d %%i in ("%SystemRoot%\Temp\*") do @rd /s /q "%%i" 2>nul
del /q/f/s "%SystemRoot%\Prefetch\*" 2>nul
del /q/f/s "%SystemRoot%\SoftwareDistribution\Download\*" 2>nul
for /d %%i in ("%SystemRoot%\SoftwareDistribution\Download\*") do @rd /s /q "%%i" 2>nul
del /q/f/s "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*" 2>nul
del /q/f/s "%LOCALAPPDATA%\Microsoft\Windows\WER\*" 2>nul
del /q/f/s "%ProgramData%\Microsoft\Windows\WER\*" 2>nul
del /q/f/s "%LOCALAPPDATA%\Microsoft\Windows\INetCache\*" 2>nul
del /q/f/s "%LOCALAPPDATA%\Microsoft\Windows\INetCookies\*" 2>nul
del /q/f/s "%SystemRoot%\Logs\CBS\*.log" 2>nul
del /q/f/s "%SystemRoot%\Logs\DISM\*.log" 2>nul
del /q/f/s "%LOCALAPPDATA%\CrashDumps\*" 2>nul
del /q/f/s "%SystemRoot%\Minidump\*" 2>nul
del /q/f/s "%SystemRoot%\LiveKernelReports\*" 2>nul

:: ================================================================
:: [2/15] FLUSH DNS
:: ================================================================
echo [2/15] Flushing DNS cache...
ipconfig /flushdns >nul 2>&1

:: ================================================================
:: [3/15] ULTIMATE POWER SETTINGS
:: ================================================================
echo [3/15] Activating Ultimate Performance power plan...
:: Unhide Ultimate Performance plan
powercfg /list | findstr /i "Ultimate" >nul 2>&1
if %errorlevel% neq 0 powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
:: Activate it (falls back to High Performance if unavailable)
set "ACTIVATED=0"
for /f "tokens=4" %%a in ('powercfg /list ^| findstr /i "Ultimate"') do (
    powercfg /setactive %%a >nul 2>&1
    set "ACTIVATED=1"
)
if "%ACTIVATED%"=="0" powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
:: Disable hibernation (frees disk space = RAM size)
powercfg /h off >nul 2>&1
:: Reduce boot menu timeout
bcdedit /timeout 3 >nul 2>&1
:: Disable Power Throttling globally
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v PowerThrottlingOff /t REG_DWORD /d 1 /f >nul 2>&1
:: Disable USB selective suspend
powercfg /setacvalueindex scheme_current 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 >nul 2>&1
powercfg /setdcvalueindex scheme_current 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 >nul 2>&1
:: Disable PCI Express Link State Power Management
powercfg /setacvalueindex scheme_current 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0 >nul 2>&1
powercfg /setdcvalueindex scheme_current 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0 >nul 2>&1
:: Apply power changes
powercfg /setactive scheme_current >nul 2>&1

:: ================================================================
:: [4/15] CPU SCHEDULER OPTIMIZATION
:: ================================================================
echo [4/15] Tuning CPU scheduler for max responsiveness...
:: Win32PrioritySeparation = 0x26 (38): Short, Fixed, Foreground boosted 3:1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 38 /f >nul 2>&1
:: Max CPU to foreground
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f >nul 2>&1
:: MMCSS Game task
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d High /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d High /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Background Only" /t REG_SZ /d False /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Clock Rate" /t REG_DWORD /d 10000 /f >nul 2>&1
:: MMCSS Pro Audio task
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" /v "Priority" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Pro Audio" /v "Scheduling Category" /t REG_SZ /d High /f >nul 2>&1

:: ================================================================
:: [5/15] GPU OPTIMIZATION
:: ================================================================
echo [5/15] Maximizing GPU performance...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
:: Hardware-Accelerated GPU Scheduling
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f >nul 2>&1
:: Disable Game DVR
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f >nul 2>&1
:: Disable fullscreen optimizations (lower input lag)
reg add "HKCU\System\GameConfigStore" /v GameDVR_FSEBehaviorMode /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v GameDVR_HonorUserFSEBehaviorMode /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v GameDVR_DXGIHonorFSEWindowsCompatible /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v GameDVR_EFSEFeatureFlags /t REG_DWORD /d 0 /f >nul 2>&1
:: Keep Game Mode ON
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 1 /f >nul 2>&1

:: ================================================================
:: [6/15] ULTIMATE NETWORK OPTIMIZATION
:: ================================================================
echo [6/15] Applying ultimate network stack optimizations...

:: --- LAYER 1: Remove Windows network throttling ---
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 0xffffffff /f >nul 2>&1

:: --- LAYER 2: TCP/IP global stack tuning ---
:: Reduce TIME_WAIT socket recycle to 30s (default 120s) - faster port reuse
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpTimedWaitDelay /t REG_DWORD /d 30 /f >nul 2>&1
:: Expand ephemeral port range to max (prevents port exhaustion)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v MaxUserPort /t REG_DWORD /d 65534 /f >nul 2>&1
:: Reduce max data retransmissions (faster timeout on dead connections)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpMaxDataRetransmissions /t REG_DWORD /d 3 /f >nul 2>&1
:: Set optimal TTL
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DefaultTTL /t REG_DWORD /d 64 /f >nul 2>&1

:: --- LAYER 3: Disable Nagle's Algorithm on ALL network interfaces ---
:: (Sends packets immediately instead of buffering - reduces latency)
for /f "tokens=*" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" 2^>nul') do (
    reg add "%%a" /v TcpNoDelay /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "%%a" /v TcpAckFrequency /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "%%a" /v TcpDelAckTicks /t REG_DWORD /d 0 /f >nul 2>&1
)

:: --- LAYER 4: Netsh TCP stack tuning ---
:: Enable Receive Side Scaling (multi-core network processing)
netsh int tcp set global rss=enabled >nul 2>&1
:: Enable Direct Cache Access (NIC writes directly to CPU cache)
netsh int tcp set global dca=enabled >nul 2>&1
:: Set auto-tuning to normal (best for most connections)
netsh int tcp set global autotuninglevel=normal >nul 2>&1
:: Disable ECN (some routers drop ECN-marked packets)
netsh int tcp set global ecncapability=disabled >nul 2>&1
:: Disable TCP timestamps (reduces packet header overhead by 12 bytes)
netsh int tcp set global timestamps=disabled >nul 2>&1
:: Disable non-SACK RTT resiliency (reduces latency in packet loss scenarios)
netsh int tcp set global nonsackrttresiliency=disabled >nul 2>&1
:: Enable TCP Fast Open (faster connection handshakes)
netsh int tcp set global fastopen=enabled >nul 2>&1
:: Reduce initial retransmission timeout
netsh int tcp set global initialRto=2000 >nul 2>&1
:: Reduce max SYN retransmissions (faster timeout on unreachable hosts)
netsh int tcp set global maxsynretransmissions=2 >nul 2>&1

:: --- LAYER 5: DNS resolution priority ---
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v LocalPriority /t REG_DWORD /d 4 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v HostsPriority /t REG_DWORD /d 5 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v DnsPriority /t REG_DWORD /d 6 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\ServiceProvider" /v NetbtPriority /t REG_DWORD /d 7 /f >nul 2>&1

:: --- LAYER 6: Set fastest DNS servers (Cloudflare 1.1.1.1) ---
:: Applied to all active adapters
for /f "tokens=3*" %%a in ('netsh interface show interface ^| findstr /i "Connected"') do (
    netsh interface ipv4 set dnsservers "%%b" static 1.1.1.1 primary validate=no >nul 2>&1
    netsh interface ipv4 add dnsservers "%%b" 1.0.0.1 index=2 validate=no >nul 2>&1
)

:: --- LAYER 7: Disable Delivery Optimization (P2P upload) ---
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode /t REG_DWORD /d 0 /f >nul 2>&1

:: ================================================================
:: [7/15] MEMORY AND STORAGE OPTIMIZATION
:: ================================================================
echo [7/15] Optimizing memory and storage...
:: Keep kernel in RAM
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v DisablePagingExecutive /t REG_DWORD /d 1 /f >nul 2>&1
:: NTFS: disable last access timestamp
fsutil behavior set disablelastaccess 1 >nul 2>&1
:: NTFS: disable 8.3 filenames
fsutil behavior set disable8dot3 1 >nul 2>&1
:: NTFS: increase memory usage
fsutil behavior set memoryusage 2 >nul 2>&1

:: ================================================================
:: [8/15] SECURITY (KEPT - VBS/HVCI stays ON)
:: ================================================================
echo [8/15] Security: VBS and Memory Integrity KEPT ENABLED.
:: NOT disabling VBS/HVCI - user wants security maintained
:: If you want 5-10%% FPS boost and accept the security trade-off,
:: uncomment these two lines:
:: reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 0 /f >nul 2>&1
:: reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v Enabled /t REG_DWORD /d 0 /f >nul 2>&1

:: ================================================================
:: [9/15] STOP EDGE, WEBVIEW2, WHATSAPP, COPILOT AT STARTUP
:: ================================================================
echo [9/15] Blocking Edge, WebView2, WhatsApp, Copilot at startup...
:: --- MICROSOFT EDGE ---
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v AllowPrelaunch /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v BackgroundModeEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v StartupBoostEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" /v AllowPrelaunch /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v TabPreloader /t REG_DWORD /d 0 /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v MicrosoftEdgeAutoLaunch* /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v MicrosoftEdgeAutoLaunch* /f >nul 2>&1
:: --- EDGE WEBVIEW2 ---
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge\WebView2" /v ReleaseChannelPreference /t REG_DWORD /d 0 /f >nul 2>&1
taskkill /f /im msedge.exe >nul 2>&1
taskkill /f /im msedgewebview2.exe >nul 2>&1
:: --- WHATSAPP ---
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v WhatsApp /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "com.squirrel.WhatsApp.WhatsApp" /f >nul 2>&1
taskkill /f /im WhatsApp.exe >nul 2>&1
:: --- COPILOT (stopped at startup, NOT removed/uninstalled) ---
reg add "HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 1 /f >nul 2>&1
:: --- EDGE AUTO-UPDATE ---
reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v UpdateDefault /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate" /v AutoUpdateCheckPeriodMinutes /t REG_DWORD /d 0 /f >nul 2>&1
taskkill /f /im MicrosoftEdgeUpdate.exe >nul 2>&1

:: ================================================================
:: [10/15] BLOATWARE AND ADS REMOVAL
:: ================================================================
echo [10/15] Stripping bloatware and ads...
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-310093Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338393Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-353698Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-353696Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SilentInstalledAppsEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v ContentDeliveryAllowed /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v OemPreInstalledAppsEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v PreInstalledAppsEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v PreInstalledAppsEverEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SystemPaneSuggestionsEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SoftLandingEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v RotatingLockScreenEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v RotatingLockScreenOverlayEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowSyncProviderNotifications /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v StartupDelayInMSec /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableWindowsConsumerFeatures /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v DisableCloudOptimizedContent /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v AllowNewsAndInterests /t REG_DWORD /d 0 /f >nul 2>&1

:: ================================================================
:: [11/15] TELEMETRY NUCLEAR LOCKDOWN
:: ================================================================
echo [11/15] Nuking all telemetry and data collection...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Siuf\Rules" /v NumberOfSIUFInPeriod /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v AITEnable /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v CEIPEnable /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v DisableInventory /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v RestrictImplicitInkCollection /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /v RestrictImplicitTextCollection /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableActivityFeed /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v PublishUserActivities /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v UploadUserActivities /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" /v TailoredExperiencesWithDiagnosticDataEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" /v HasAccepted /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" /v ShowedToastAtLevel /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v DisableLocation /f >nul 2>&1

:: ================================================================
:: [12/15] STOP UNWANTED SERVICES PERMANENTLY
:: ================================================================
echo [12/15] Killing unwanted background services...
sc stop SysMain >nul 2>&1 & sc config SysMain start=disabled >nul 2>&1
sc stop DiagTrack >nul 2>&1 & sc config DiagTrack start=disabled >nul 2>&1
sc stop dmwappushservice >nul 2>&1 & sc config dmwappushservice start=disabled >nul 2>&1
sc stop WerSvc >nul 2>&1 & sc config WerSvc start=disabled >nul 2>&1
sc stop wisvc >nul 2>&1 & sc config wisvc start=disabled >nul 2>&1
sc stop MapsBroker >nul 2>&1 & sc config MapsBroker start=disabled >nul 2>&1
sc stop Fax >nul 2>&1 & sc config Fax start=disabled >nul 2>&1
sc stop RemoteRegistry >nul 2>&1 & sc config RemoteRegistry start=disabled >nul 2>&1
sc stop RetailDemo >nul 2>&1 & sc config RetailDemo start=disabled >nul 2>&1
sc stop diagsvc >nul 2>&1 & sc config diagsvc start=disabled >nul 2>&1
sc stop WdiServiceHost >nul 2>&1 & sc config WdiServiceHost start=demand >nul 2>&1
sc stop AJRouter >nul 2>&1 & sc config AJRouter start=disabled >nul 2>&1

:: ================================================================
:: [13/15] KILL BACKGROUND PROCESSES
:: ================================================================
echo [13/15] Killing lingering background processes...
taskkill /f /im msedge.exe >nul 2>&1
taskkill /f /im msedgewebview2.exe >nul 2>&1
taskkill /f /im WhatsApp.exe >nul 2>&1
taskkill /f /im MicrosoftEdgeUpdate.exe >nul 2>&1

:: ================================================================
:: [14/15] ADDITIONAL PERFORMANCE TWEAKS
:: ================================================================
echo [14/15] Applying final performance tweaks...
:: IRQ8 priority boost (system timer precision)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v IRQ8Priority /t REG_DWORD /d 1 /f >nul 2>&1
:: Faster shutdown (2s kill timeout instead of 20s)
reg add "HKCU\Control Panel\Desktop" /v WaitToKillAppTimeout /t REG_SZ /d 2000 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v WaitToKillServiceTimeout /t REG_SZ /d 2000 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v HungAppTimeout /t REG_SZ /d 1000 /f >nul 2>&1
:: Faster Explorer (bigger icon cache)
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "Max Cached Icons" /t REG_SZ /d 4096 /f >nul 2>&1
:: Faster tooltips
reg add "HKCU\Control Panel\Mouse" /v MouseHoverTime /t REG_SZ /d 10 /f >nul 2>&1
:: Disable web results in Start search (saves bandwidth + CPU)
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v DisableSearchBoxSuggestions /t REG_DWORD /d 1 /f >nul 2>&1

:: ================================================================
:: [15/15] MAKE PERMANENT (Auto-run on Every Boot)
:: ================================================================
echo [15/15] Making OPTMX permanent on startup...
copy "%~f0" "C:\Windows\System32\OPTMX_AutoRun.bat" /Y >nul 2>&1
schtasks /create /tn "OPTMX_PermanentOptimizer" /tr "C:\Windows\System32\OPTMX_AutoRun.bat" /sc onstart /ru SYSTEM /rl HIGHEST /f >nul 2>&1
echo Fixed Location...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v DisableLocation /t REG_DWORD /d 0 /f

echo.
echo  ================================================================
echo    OPTMX v3.0 - ALL OPTIMIZATIONS APPLIED!
echo.
echo    Cache:           NUKED
echo    Power Plan:      ULTIMATE PERFORMANCE
echo    Power Throttle:  DISABLED
echo    CPU Scheduler:   FOREGROUND 3:1 BOOST
echo    GPU:             MAX PRIORITY + HW SCHEDULING
echo    Security:        VBS/HVCI KEPT ON
echo    Network:         7-LAYER OPTIMIZATION APPLIED
echo      - Nagle OFF on all interfaces
echo      - TCP Fast Open enabled
echo      - Timestamps OFF (12-byte header saving)
echo      - Max ports 65534, TIME_WAIT 30s
echo      - RSS + DCA enabled
echo      - DNS set to Cloudflare 1.1.1.1
echo      - Delivery Optimization P2P OFF
echo    Memory:          KERNEL LOCKED IN RAM
echo    Storage:         NTFS OPTIMIZED
echo    Edge:            BLOCKED AT STARTUP
echo    WebView2:        KILLED
echo    WhatsApp:        BLOCKED AT STARTUP
echo    Copilot:         STOPPED AT STARTUP
echo    Telemetry:       KILLED
echo    Services:        12 STOPPED
echo    Visuals:         UNCHANGED
echo    Startup:         PERMANENT
echo.
echo    ^>^>^> REBOOT NOW to fully apply all changes ^<^<^<
echo  ================================================================
pause >nul
