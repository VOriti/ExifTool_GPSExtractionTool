@echo off
setlocal ENABLEDELAYEDEXPANSION

REM ================== Config ==================
set "HERE=%~dp0"
set "OUT=%HERE%GPSData_extracted"
set "GPXFMT=%HERE%gpx.fmt"
set "KMLFMT=%HERE%kml_track.fmt"
set "KMLPOINTS=%HERE%kml_points.fmt"
set "EXIF=%HERE%exiftool.exe"

REM ================== Controlli preliminari ==================
if not exist "%EXIF%" (
  echo [ERRORE] exiftool.exe non trovato. Metti exiftool.exe dentro la cartella GPSExtract accanto a questo .bat.
  pause
  exit /b 1
)

REM Cartella superiore (sorgente assoluta)
for %%I in ("%HERE%..") do set "SRC=%%~fI"

REM ================== Preparazione output ==================
if not exist "%OUT%" mkdir "%OUT%"

REM ================== Template GPX (track) ==================
if not exist "%GPXFMT%" (
  (
    echo ^<?xml version="1.0" encoding="UTF-8"?^>
    echo ^<gpx version="1.1" creator="ExifTool" xmlns="http://www.topografix.com/GPX/1/1"^>
    echo   ^<metadata^>^<name^>Photo Track^</name^>^</metadata^>
    echo   ^<trk^>^<name^>Photo Track^</name^>^<trkseg^>
    echo #[BODY]  ^<trkpt lat="$GPSLatitude#" lon="$GPSLongitude#"^>^<time^>$DateTimeOriginal^</time^>^<$if($GPSAltitude,"ele")^>$GPSAltitude^</$if($GPSAltitude,"ele")^>^</trkpt^>
    echo #[TAIL]  ^</trkseg^>^</trk^>
    echo ^</gpx^>
  ) > "%GPXFMT%"
)

REM ================== Template KML (gx:Track) ==================
if not exist "%KMLFMT%" (
  (
    echo ^<?xml version="1.0" encoding="UTF-8"?^>
    echo ^<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2"^>
    echo ^<Document^>
    echo   ^<name^>Photo Track^</name^>
    echo   ^<Placemark^>
    echo     ^<name^>Photo Track^</name^>
    echo     ^<gx:Track^>
    echo #[BODY]      ^<when^>$DateTimeOriginal^</when^>
    echo #[BODY]      ^<gx:coord^>$GPSLongitude# $GPSLatitude# $if($GPSAltitude,$GPSAltitude#,0)^</gx:coord^>
    echo #[TAIL]    ^</gx:Track^>
    echo   ^</Placemark^>
    echo ^</Document^>
    echo ^</kml^>
  ) > "%KMLFMT%"
)

REM ================== Template KML (Placemark per punti con ExtendedData) ==================
if not exist "%KMLPOINTS%" (
  (
    echo ^<?xml version="1.0" encoding="UTF-8"?^>
    echo ^<kml xmlns="http://www.opengis.net/kml/2.2"^>
    echo ^<Document^>
    echo   ^<name^>Photo Points^</name^>
    echo #[BODY]  ^<Placemark^>
    echo            ^<name^>$FileName^</name^>
    echo            ^<TimeStamp^>^<when^>$DateTimeOriginal^</when^>^</TimeStamp^>
    echo            ^<description^>$Directory^</description^>
    echo            ^<ExtendedData^>
    echo              ^<Data name="Directory"^>^<value^>$Directory^</value^>^</Data^>
    echo              ^<Data name="FileSize"^>^<value^>$FileSize^</value^>^</Data^>
    echo              ^<Data name="MIMEType"^>^<value^>$MIMEType^</value^>^</Data^>
    echo              ^<Data name="Make"^>^<value^>$Make^</value^>^</Data^>
    echo              ^<Data name="Model"^>^<value^>$Model^</value^>^</Data^>
    echo              ^<Data name="LensModel"^>^<value^>$LensModel^</value^>^</Data^>
    echo              ^<Data name="Software"^>^<value^>$Software^</value^>^</Data^>
    echo              ^<Data name="ImageWidth"^>^<value^>$ImageWidth^</value^>^</Data^>
    echo              ^<Data name="ImageHeight"^>^<value^>$ImageHeight^</value^>^</Data^>
    echo              ^<Data name="Orientation"^>^<value^>$Orientation^</value^>^</Data^>
    echo              ^<Data name="ShutterSpeed"^>^<value^>$ShutterSpeed^</value^>^</Data^>
    echo              ^<Data name="Aperture"^>^<value^>$Aperture^</value^>^</Data^>
    echo              ^<Data name="ISO"^>^<value^>$ISO^</value^>^</Data^>
    echo              ^<Data name="FocalLength"^>^<value^>$FocalLength^</value^>^</Data^>
    echo              ^<Data name="GPSLatitude"^>^<value^>$GPSLatitude#^</value^>^</Data^>
    echo              ^<Data name="GPSLongitude"^>^<value^>$GPSLongitude#^</value^>^</Data^>
    echo              ^<Data name="GPSAltitude"^>^<value^>$GPSAltitude#^</value^>^</Data^>
    echo              ^<Data name="GPSImgDirection"^>^<value^>$GPSImgDirection#^</value^>^</Data^>
    echo              ^<Data name="GPSMeasureMode"^>^<value^>$GPSMeasureMode^</value^>^</Data^>
    echo              ^<Data name="GPSHPositioningError"^>^<value^>$GPSHPositioningError^</value^>^</Data^>
    echo              ^<Data name="GPSDOP"^>^<value^>$GPSDOP^</value^>^</Data^>
    echo            ^</ExtendedData^>
    echo            ^<Point^>^<coordinates^>$GPSLongitude#,$GPSLatitude#,$if($GPSAltitude,$GPSAltitude#,0)^</coordinates^>^</Point^>
    echo          ^</Placemark^>
    echo #[TAIL] ^</Document^>
    echo ^</kml^>
  ) > "%KMLPOINTS%"
)

REM ================== CSV completo e ordinato ==================
"%EXIF%" -csv -n -r -fileOrder DateTimeOriginal -x "%HERE%" -x "%OUT%" ^
  -FileName -Directory -FileSize -MIMEType ^
  -Make -Model -LensModel -Software ^
  -Orientation -ImageWidth -ImageHeight ^
  -DateTimeOriginal -CreateDate -ModifyDate -GPSDateStamp -GPSTimeStamp ^
  -GPSLatitude -GPSLongitude -GPSAltitude -GPSImgDirection -GPSMeasureMode -GPSHPositioningError -GPSDOP ^
  -ShutterSpeed -Aperture -ISO -FocalLength ^
  "%SRC%" > "%OUT%\gps_sorted.csv"

REM ================== GPX (track.gpx) ==================
"%EXIF%" -r -if "defined $GPSLatitude and defined $GPSLongitude" -fileOrder DateTimeOriginal ^
  -x "%HERE%" -x "%OUT%" ^
  -d "%%Y-%%m-%%dT%%H:%%M:%%SZ" -p "%GPXFMT%" "%SRC%" > "%OUT%\track.gpx"

REM ================== KML track (gx:Track) ==================
"%EXIF%" -n -r -if "defined $GPSLatitude and defined $GPSLongitude" -fileOrder DateTimeOriginal ^
  -x "%HERE%" -x "%OUT%" ^
  -d "%%Y-%%m-%%dT%%H:%%M:%%SZ" -p "%KMLFMT%" "%SRC%" > "%OUT%\track.kml"

REM ================== KML points (Placemark + ExtendedData) ==================
"%EXIF%" -n -r -if "defined $GPSLatitude and defined $GPSLongitude" -fileOrder DateTimeOriginal ^
  -x "%HERE%" -x "%OUT%" ^
  -d "%%Y-%%m-%%dT%%H:%%M:%%SZ" -p "%KMLPOINTS%" "%SRC%" > "%OUT%\points.kml"

echo.
echo ✅ Fatto! File creati in:
echo    "%OUT%\gps_sorted.csv"
echo    "%OUT%\track.gpx"
echo    "%OUT%\track.kml"
echo    "%OUT%\points.kml"
pause
