@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 1252 >nul

REM =========================
REM =   CONFIGURAZIONE     =
REM =========================
set "HERE=%~dp0"
set "EXIF=%HERE%exiftool.exe"
set "OUT=%HERE%GPSData_extracted"

REM Toggle diagnostica (0=silenziato, 1=verbose + log warning)
set "DIAG=1"

if not exist "%EXIF%" (
  echo [ERRORE] exiftool.exe non trovato in "%HERE%"
  pause & exit /b 1
)

REM Cartella superiore (sorgente media)
pushd "%~dp0.."
set "SRC=%CD%"
popd

if not exist "%OUT%" mkdir "%OUT%"

REM Lavoriamo dentro la cartella sorgente per evitare problemi di path con caratteri accentati
pushd "%SRC%"

REM Opzioni comuni: ricorsivo, valori numerici, estensioni ammesse, escludi cartella tool/output (relativa)
set "INCLUDE=-r -n -ext jpg -ext jpeg -ext mp4 -ext mov -ext heic -i ./GPSExtractionTool -i ./GPSExtractionTool/*"

REM =========================
REM =  CSV COMPLETO (foto+video)
REM =========================
if exist "%OUT%\gps_sorted.csv" del "%OUT%\gps_sorted.csv" >nul 2>nul
"%EXIF%" %INCLUDE% -csv ^
  -i "%HERE%." -i "%OUT%." ^
  -FileName -Directory -FileSize -MIMEType ^
  -Make -Model -LensModel -Software -Orientation -ImageWidth -ImageHeight ^
  -CreateDate -ModifyDate -DateTimeOriginal -GPSDateStamp -GPSTimeStamp ^
  -GPSLatitude -GPSLongitude -GPSAltitude -GPSImgDirection -GPSMeasureMode -GPSHPositioningError -GPSDOP ^
  -MediaCreateDate -TrackCreateDate -GPSDateTime ^
  . > "%OUT%\gps_sorted.csv"

REM =========================
REM =  KML POINTS (1 punto per file con GPS)
REM =  Estrai CSV temporaneo -> genera KML via loop
REM =========================
"%EXIF%" %INCLUDE% -csv ^
  -i "%HERE%." -i "%OUT%." ^
  -if "defined $GPSLatitude and defined $GPSLongitude" ^
  "-FileName" "-Directory" "-BestDateTime" "-GPSLongitude#" "-GPSLatitude#" "-GPSAltitude#" ^
  . > "%OUT%\_points.csv"

> "%OUT%\points.kml" (
  echo ^<?xml version="1.0" encoding="UTF-8"?^>
  echo ^<kml xmlns="http://www.opengis.net/kml/2.2"^>
  echo ^<Document^>
  echo   ^<name^>Photo Points^</name^>
)
for /f "usebackq skip=1 tokens=1-6 delims=," %%A in ("%OUT%\_points.csv") do (
  >> "%OUT%\points.kml" echo   ^<Placemark^>
  >> "%OUT%\points.kml" echo     ^<name^>%%A^</name^>
  >> "%OUT%\points.kml" echo     ^<TimeStamp^>^<when^>%%C^</when^>^</TimeStamp^>
  >> "%OUT%\points.kml" echo     ^<description^>%%B^</description^>
  >> "%OUT%\points.kml" echo     ^<Point^>^<coordinates^>%%D,%%E,%%F^</coordinates^>^</Point^>
  >> "%OUT%\points.kml" echo   ^</Placemark^>
)
>> "%OUT%\points.kml" (
  echo ^</Document^>
  echo ^</kml^>
)
del "%OUT%\_points.csv" >nul 2>nul

REM =========================
REM =  TRACCIA GPX/KML (campioni densi da video)
REM =  Estrai punti in CSV -> genera GPX/KML via loop
REM =========================
REM Estrazione campioni: usa -ee per stream embedded, QuickTimeUTC per timestamp coerenti, ordinati per gpsdatetime
if "%DIAG%"=="1" (
  echo [DIAG] Modalita' diagnostica ATTIVA. Warning anche su schermo e log in "%OUT%\warnings.log".
  "%EXIF%" %INCLUDE% -i "%HERE%." -i "%OUT%." -ee -api QuickTimeUTC -fileOrder gpsdatetime ^
    -p "$gpsdatetime,$gpslatitude,$gpslongitude,$gpsaltitude" . > "%OUT%\_track_pts.csv" 2>>"%OUT%\warnings.log"
) else (
  "%EXIF%" %INCLUDE% -i "%HERE%." -i "%OUT%." -ee -api QuickTimeUTC -fileOrder gpsdatetime -q -q ^
    -p "$gpsdatetime,$gpslatitude,$gpslongitude,$gpsaltitude" . > "%OUT%\_track_pts.csv" 2>nul
)

REM GPX: header
> "%OUT%\track.gpx" (
  echo ^<?xml version="1.0" encoding="UTF-8"?^>
  echo ^<gpx version="1.1" creator="GPSExtractionTool" xmlns="http://www.topografix.com/GPX/1/1"^>
  echo   ^<trk^>^<name^>traccia^</name^>^<trkseg^>
)
REM GPX: body
if exist "%OUT%\_track_pts.csv" (
  for /f "usebackq tokens=1-4 delims=," %%A in ("%OUT%\_track_pts.csv") do (
    if not "%%A"=="" (
      >> "%OUT%\track.gpx" echo     ^<trkpt lat="%%B" lon="%%C"^>^<time^>%%A^</time^>^<ele^>%%D^</ele^>^</trkpt^>
    )
  )
)
REM GPX: footer
>> "%OUT%\track.gpx" echo   ^</trkseg^>^</trk^>^</gpx^>

REM KML Track: header
> "%OUT%\track.kml" (
  echo ^<?xml version="1.0" encoding="UTF-8"?^>
  echo ^<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2"^>
  echo ^<Document^>^<name^>traccia^</name^>^<Placemark^>^<name^>traccia^</name^>^<gx:Track^>
)
REM KML Track: body
if exist "%OUT%\_track_pts.csv" (
  for /f "usebackq tokens=1-4 delims=," %%A in ("%OUT%\_track_pts.csv") do (
    if not "%%A"=="" (
      >> "%OUT%\track.kml" echo       ^<when^>%%A^</when^>
      >> "%OUT%\track.kml" echo       ^<gx:coord^>%%C %%B %%D^</gx:coord^>
    )
  )
)
REM KML Track: footer
>> "%OUT%\track.kml" echo     ^</gx:Track^>^</Placemark^>^</Document^>^</kml^>

if exist "%OUT%\_track_pts.csv" del "%OUT%\_track_pts.csv" >nul 2>nul

REM Torna dalla cartella sorgente
popd

REM =========================
REM =  RIEPILOGO
REM =========================
set "TP=0" & set "KC=0" & set "PC=0" & set "CSVROWS=0" & set "CSVREC=0"
if exist "%OUT%\track.gpx"  for /f %%N in ('find /c "<trkpt" ^< "%OUT%\track.gpx"') do set "TP=%%N"
if exist "%OUT%\track.kml"  for /f %%N in ('find /c "<gx:coord>" ^< "%OUT%\track.kml"') do set "KC=%%N"
if exist "%OUT%\points.kml" for /f %%N in ('find /c "<Placemark>" ^< "%OUT%\points.kml"') do set "PC=%%N"
if exist "%OUT%\gps_sorted.csv" (
  for /f %%N in ('type "%OUT%\gps_sorted.csv" ^| find /c /v ""') do set "CSVROWS=%%N"
  set /a CSVREC=CSVROWS-1
  if %CSVREC% LSS 0 set "CSVREC=0"
)

echo.
echo -------- RIEPILOGO --------
echo  CSV   (righe dati): %CSVREC%
echo  GPX   (trkpt)     : %TP%
echo  KML T (gx:coord)  : %KC%
echo  KML P (Placemark) : %PC%
echo ---------------------------
if "%DIAG%"=="1" echo [DIAG] Log warning: "%OUT%\warnings.log"
pause
