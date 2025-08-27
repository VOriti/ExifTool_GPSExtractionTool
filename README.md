# GPSExtractionTool

**Descrizione / Description**
---
🇮🇹  Un semplice script portatile che utilizza ExifTool per estrarre in blocco i dati GPS e i metadati da una cartella di foto e video.
Genera automaticamente:
   - CSV con informazioni complete sui file e coordinate
   - GPX con la traccia georeferenziata
   - KML (track e points) per visualizzare percorsi e punti in Google Earth, QGIS e altri software GIS

🇬🇧  A simple portable script that leverages ExifTool to bulk-extract GPS data and metadata from a folder of photos and videos.
It automatically generates:
   - CSV with full file information and coordinates
   - GPX with the georeferenced track
   - KML (track and points) to visualize routes and locations in Google Earth, QGIS, and other GIS software

---
**INSTRUCTIONS**
---
**ITALIAN – ENGLISH BELOW**
---

## Operazione preliminare

0. Scarica **ExifTool**  
   - Scarica il software da [https://exiftool.org](https://exiftool.org)  
   - Copia il file dentro la cartella **`GPSExtract`**, poi rinominalo in `exiftool.exe`, insieme alla cartella `exiftool_files`, se presente


---

## Utilizzo rapido

1. Copia l’intera cartella **`GPSExtract`** (contenente `exiftool.exe` e `extract_gps.bat`)  
   dentro la cartella che contiene le foto o i video da analizzare.  
   *Esempio:*  
   ```
   D:\Viaggi\2024\Foto\GPSExtract\
   ```

2. Apri la cartella `GPSExtract` e fai doppio click su:  
   ```
   extract_gps.bat
   ```

3. Lo script analizzerà automaticamente **tutti i file multimediali** presenti nella **cartella superiore** (dove si trovano le foto), escludendo i propri file interni.

4. I risultati saranno salvati in:  
   ```
   GPSExtract\GPSData_extracted\
   ```

---

## 📊 File di output

| File             | Formato | Contenuto principale           |
|------------------|---------|--------------------------------|
| **gps_sorted.csv** | CSV     | Tabella con metadati completi |
| **track.gpx**     | GPX 1.1 | Traccia georeferenziata        |
| **track.kml**     | KML     | Percorso temporale (gx:Track)  |
| **points.kml**    | KML     | Punti singoli con metadati     |

---

## 📂 Dettaglio file

### 1. gps_sorted.csv
- Tabella apribile in **Excel / LibreOffice / Google Sheets**  
- Colonne principali:  
  - FileName, Directory, FileSize, MIMEType  
  - Make, Model, LensModel, Software  
  - ImageWidth, ImageHeight, Orientation  
  - DateTimeOriginal, CreateDate, ModifyDate, GPSDateStamp, GPSTimeStamp  
  - GPSLatitude, GPSLongitude, GPSAltitude, GPSImgDirection  
  - ISO, ShutterSpeed, Aperture, FocalLength  
- Ordinato cronologicamente per `DateTimeOriginal`  
👉 Ideale per analisi dettagliate, filtri, statistiche, esportazioni in GIS

### 2. track.gpx
- Formato **GPX 1.1 standard**
- Contiene una **traccia (trk)** con tutti i punti geotaggati in ordine temporale
- Ogni punto include latitudine, longitudine, altitudine (se presente), timestamp  
👉 Perfetto per dispositivi GPS, Garmin BaseCamp, QGIS, Google Earth (import GPX)

### 3. track.kml
- Formato **KML** con estensione Google (`gx:Track`)  
- Sequenza temporale di tutti i punti con animazione della timeline  
👉 Ottimo per rivedere il viaggio in Google Earth come animazione temporale

### 4. points.kml
- Formato **KML** con un **Placemark per ogni foto/video**
- Nome = FileName, descrizione = Directory  
- Include `TimeStamp` e coordinate  
- ExtendedData con metadati (fotocamera, lente, ISO, focale, ecc.)  
👉 Utile in Google Earth / QGIS se vuoi i punti singoli con dettagli tecnici

---

## 💡 Consigli d’uso

- Vuoi un’analisi tabellare (filtri, grafici, pivot)?  
  → **gps_sorted.csv** (Excel, Google Sheets, LibreOffice Calc)

- Vuoi caricare il percorso su un GPS o app sportiva?  
  → **track.gpx** (Garmin, Strava, Komoot, QGIS, MapSource)

- Vuoi rivedere il viaggio in Google Earth con animazione temporale?  
  → **track.kml** (gx:Track)

- Vuoi vedere ogni foto come punto con dettagli tecnici?  
  → **points.kml** (Google Earth, QGIS)

---

## 📌 Note

- Le colonne/elementi possono essere vuoti se il file non contiene quel metadato.  
- ExifTool supporta molti formati (JPG, PNG, HEIC, RAW, MP4, MOV...).  
- Google Earth preferisce i KML, ma importa anche i GPX.  
- QGIS può importare direttamente **CSV, GPX e KML**.  
- Se i dati temporali mancano, l’ordinamento cronologico potrebbe non essere accurato.  

---

## ⚙️ Flusso di esecuzione

1. **Controllo preliminare**
   - Lo script verifica la presenza di `exiftool.exe`
   - Se manca → errore e stop.

2. **Individuazione sorgente**
   - Viene analizzata la **cartella superiore** rispetto a `GPSExtract` (dove si trovano le foto).
   - Esclude la cartella degli strumenti e l’output (`GPSExtract`, `GPSData_extracted`).

3. **Preparazione output**
   - Se non esiste, viene creata `GPSData_extracted` accanto allo script.

4. **Generazione template**
   - Se mancanti, vengono creati i file di formattazione locali:
     - `gpx.fmt` → struttura del file GPX
     - `kml_track.fmt` → struttura KML con percorso (gx:Track)
     - `kml_points.fmt` → struttura KML con punti e metadati

5. **Estrazione CSV**
   - Genera `gps_sorted.csv` con metadati completi (camera, parametri di scatto, GPS).
   - Ordinato cronologicamente per `DateTimeOriginal`.

6. **Generazione GPX**
   - Produce `track.gpx` con i punti georeferenziati (lat, lon, alt, time).

7. **Generazione KML (track)**
   - Produce `track.kml` con percorso temporale (`gx:Track`), animabile in Google Earth.

8. **Generazione KML (points)**
   - Produce `points.kml` con un Placemark per ogni file e metadati in `<ExtendedData>`.

9. **Messaggio finale**
   - Lo script mostra i file creati dentro `GPSData_extracted`.

---



# 🇬🇧 English version

---

## Preliminary operation

0. Download **ExifTool**  
   - Download the software from [https://exiftool.org](https://exiftool.org)  
   - Copy the file into the **`GPSExtract`** folder, then rename it to `exiftool.exe`, along with the `exiftool_files` folder, if present

---

## Quick Start

1. Copy the entire **`GPSExtract`** folder (containing `exiftool.exe` and `extract_gps.bat`)  
   inside the folder that contains the photos or videos you want to process.  
   *Example:*  
   ```
   D:\Trips\2024\Photos\GPSExtract\
   ```

2. Open the `GPSExtract` folder and double-click:  
   ```
   extract_gps.bat
   ```

3. The script will automatically scan **all media files** located in the **parent folder** (where the photos are stored), excluding its own internal files.

4. Results will be saved in:  
   ```
   GPSExtract\GPSData_extracted\
   ```

---

## 📊 Output files

| File             | Format | Main contents                  |
|------------------|--------|--------------------------------|
| **gps_sorted.csv** | CSV    | Table with complete metadata   |
| **track.gpx**     | GPX 1.1| Georeferenced track            |
| **track.kml**     | KML    | Temporal path (gx:Track)       |
| **points.kml**    | KML    | Individual points with metadata|

---

## 📂 Output details

### 1. gps_sorted.csv
- Tabular format (CSV), can be opened in **Excel / LibreOffice / Google Sheets**  
- Main columns:  
  - FileName, Directory, FileSize, MIMEType  
  - Make, Model, LensModel, Software  
  - ImageWidth, ImageHeight, Orientation  
  - DateTimeOriginal, CreateDate, ModifyDate, GPSDateStamp, GPSTimeStamp  
  - GPSLatitude, GPSLongitude, GPSAltitude, GPSImgDirection  
  - ISO, ShutterSpeed, Aperture, FocalLength  
- Chronologically ordered by `DateTimeOriginal`  
👉 Best for detailed analysis, filters, statistics, export to GIS

### 2. track.gpx
- Standard **GPX 1.1** format  
- Contains a **track (trk)** with all geotagged points in time order  
- Each point includes latitude, longitude, altitude (if available), timestamp  
👉 Perfect for GPS devices, Garmin BaseCamp, QGIS, Google Earth (import GPX)

### 3. track.kml
- **KML** format with Google extension (`gx:Track`)  
- Temporal sequence of all points with timeline animation  
👉 Great for replaying your trip in Google Earth as a time sequence

### 4. points.kml
- **KML** format with one **Placemark per photo/video**  
- Name = FileName, description = Directory  
- Includes `TimeStamp` and coordinates  
- ExtendedData with metadata (camera, lens, ISO, focal length, etc.)  
👉 Useful in Google Earth / QGIS to view individual points with technical details

---

## 💡 File usage recommendations

- Need tabular analysis (filters, charts, pivot tables)?  
  → **gps_sorted.csv** (Excel, Google Sheets, LibreOffice Calc)

- Need to upload the track to a GPS or sports app?  
  → **track.gpx** (Garmin, Strava, Komoot, QGIS, MapSource)

- Want to replay your trip in Google Earth with time animation?  
  → **track.kml** (gx:Track)

- Want to see each photo as a point with full details?  
  → **points.kml** (Google Earth, QGIS)

---

## 📌 Notes

- Columns/elements may be empty if the file does not contain that metadata.  
- ExifTool supports many formats (JPG, PNG, HEIC, RAW, MP4, MOV...).  
- Google Earth prefers KML but also imports GPX.  
- QGIS can directly import **CSV, GPX and KML**.  
- If temporal data is missing, chronological order may not be precise. 

---

## ⚙️ Execution flow

1. **Pre-check**
   - The script verifies that `exiftool.exe` exists inside `GPSExtract`.
   - If missing → error and stop.

2. **Source detection**
   - It scans the **parent folder** of `GPSExtract` (where your photos live).
   - Tool and output folders are excluded (`GPSExtract`, `GPSData_extracted`).

3. **Output preparation**
   - Creates `GPSData_extracted` next to the script if it does not exist.

4. **Template generation**
   - If missing, it creates local formatter files:
     - `gpx.fmt` → GPX track structure
     - `kml_track.fmt` → KML with `gx:Track`
     - `kml_points.fmt` → KML placemarks with metadata

5. **CSV extraction**
   - Produces `gps_sorted.csv` with complete metadata (camera, exposure, GPS).
   - Chronologically ordered by `DateTimeOriginal`.

6. **GPX generation**
   - Produces `track.gpx` with georeferenced points (lat, lon, ele, time).

7. **KML (track) generation**
   - Produces `track.kml` with a temporal path (`gx:Track`), playable in Google Earth.

8. **KML (points) generation**
   - Produces `points.kml` with one Placemark per file and `<ExtendedData>`.

9. **Final message**
   - The script prints the list of files created in `GPSData_extracted`.
