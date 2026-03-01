# -------------------------------------------------------------
#  SPEC – Introduzione all'Econometria Spaziale
#  2/3 Marzo 2026 – Teacher: Vincenzo Nardelli
# -------------------------------------------------------------

# -------------------------------------------------------------
#  0) Load required packages
# -------------------------------------------------------------

library(sf)
library(sfarrow)
library(dplyr)
library(ggplot2)

# -------------------------------------------------------------
#  Areal Data
# -------------------------------------------------------------
tanzania <- st_read_parquet("data/tanzania.parquet")

ggplot(tanzania) +
  geom_sf(aes(fill=FEFRTRWTFR))

# -------------------------------------------------------------
# Point data
# -------------------------------------------------------------
kc <- st_read_parquet("data/kc_house.parquet")

ggplot(kc) +
  geom_sf(aes(color = price), alpha = 0.3)

ggplot(kc) +
  geom_sf(aes(color = log(price)), alpha = 0.3)


# -------------------------------------------------------------
# Grid data
# -------------------------------------------------------------
kc_grid <- st_read_parquet("data/kc_grid.parquet")

ggplot(kc_grid) +
  geom_sf(aes(fill = price))

ggplot(kc_grid) +
  geom_sf(aes(fill = log(price)))