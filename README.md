# Corso Intensivo di Introduzione all'Econometria Spaziale

**2–3 Marzo 2026 | Università Cattolica del Sacro Cuore – Roma | Facoltà di Economia**

Prof. Giuseppe Arbia  - Dott. Vincenzo Nardelli - Dott. Niccolò Salvini 
---

## Obiettivi del corso

Il corso fornisce un'introduzione ai fondamenti teorici dell'econometria spaziale e alla loro applicazione empirica in **R** e **Python**, con esempi su dataset reali per comprenderne l'importanza in economia e nelle scienze sociali.

---

## Pacchetti R richiesti

```r
install.packages(c(
  "sf",          # dati vettoriali spaziali
  "sfarrow",     # lettura/scrittura file Parquet per oggetti sf
  "spdep",       # dipendenza spaziale, pesi, test
  "spatialreg",  # modelli di regressione spaziale
  "ggplot2",     # visualizzazione
  "dplyr",       # manipolazione dati
  "h3jsr",       # griglia H3
  "RColorBrewer",# palette colori
  "tseries"      # serie temporali e test
))
```

---

## Pacchetti Python richiesti

I notebook Python sono pensati per **Google Colab**; ogni notebook installa automaticamente le dipendenze. Se vuoi eseguirli in locale:

```bash
pip install geopandas pyarrow libpysal esda spreg splot mapclassify h3 matplotlib
```

---

## Come iniziare

### R
1. Clona o scarica il repository
2. Apri la cartella in RStudio
3. Installa i pacchetti richiesti (vedi sopra)
4. Esegui gli script in ordine numerico nella cartella `R/`

> I dati già pre-elaborati si trovano in `data/` in formato Parquet.
> Lo script `1_spatial_data.R` mostra come sono stati prodotti a partire da `data_raw/`.

### Python (Google Colab)
1. Apri i notebook dalla cartella `Python/` direttamente su Google Colab
2. Ogni notebook scarica i dati automaticamente da GitHub
3. Esegui le celle in ordine

---

## Download

Il materiale completo del corso (codice + dati) è scaricabile come archivio ZIP dalla [pagina del corso](https://vincnardelli.github.io/spec) oppure direttamente da GitHub:

[**Scarica ZIP**](https://github.com/vincnardelli/spec/archive/refs/heads/main.zip)

---

## Struttura del repository

```
spec/
├── R/
│   ├── 1_spatial_data.R              # Caricamento e preparazione dati spaziali
│   ├── 2_maps.R                      # Visualizzazione con mappe
│   ├── 3_lisa.R                      # Autocorrelazione spaziale globale e LISA
│   ├── 3_lisa_h3.R                   # LISA su griglia H3 (King County)
│   ├── 3_lisa_visium_hne.R           # LISA su dati puntuali kNN (Visium HNE)
│   ├── 4_spatial_model.R             # Modelli di regressione spaziale (SEM)
│   └── 5_spatial_model_selection.R   # Selezione modello (SAR, SEM, SARAR)
├── Python/
│   ├── 1_spatial_data.ipynb          # ↔ 1_spatial_data.R
│   ├── 2_maps.ipynb                  # ↔ 2_maps.R
│   ├── 3_lisa.ipynb                  # ↔ 3_lisa.R
│   ├── 3_lisa_h3.ipynb               # ↔ 3_lisa_h3.R
│   ├── 3_lisa_visium_hne.ipynb       # ↔ 3_lisa_visium_hne.R
│   ├── 4_spatial_model.ipynb         # ↔ 4_spatial_model.R
│   └── 5_spatial_model_selection.ipynb # ↔ 5_spatial_model_selection.R
├── data/
│   ├── italian_provinces.parquet     # Province italiane – NEET e formazione continua
│   ├── kc_house.parquet              # King County (WA) – prezzi immobiliari (punti)
│   ├── kc_grid.parquet               # King County – prezzi aggregati su griglia H3
│   ├── visium_hne_points.parquet     # Visium HNE – dati puntuali
│   └── tanzania.parquet              # Tanzania – indicatori DHS 2022 (areale)
├── data_raw/
│   ├── kingcounty/                   # Shapefile e CSV delle case di King County
│   └── tanzania/                     # Shapefile DHS Tanzania (livello 1 e 2)
└── spatial_econometrics_course.Rproj
```

---

## Dataset

### Province italiane (`italian_provinces.parquet`)
Dati sulle province italiane con indicatori socio-economici:
- `neet`: giovani che non lavorano e non studiano (%)
- `formazione`: partecipazione alla formazione continua (%)

### King County Housing (`kc_house.parquet`, `kc_grid.parquet`)
Dataset sui prezzi delle abitazioni nella contea di King (Washington, USA):
- Dati puntuali georeferenziati
- Versione aggregata su griglia esagonale H3 (risoluzione 8)
- Variabile chiave: `price`

### Tanzania DHS 2022 (`tanzania.parquet`)
Indicatori demografici e sanitari sub-nazionali da DHS 2022 (livello 2):
- `FEFRTRWTFR`: tasso di fecondità totale
- `AHMIGRWEMP`: tasso di migrazione
- `EDEDUCWSEH`: livello di istruzione femminile

---

## Licenza

Materiale didattico per uso accademico — Università Cattolica del Sacro Cuore, 2026.
