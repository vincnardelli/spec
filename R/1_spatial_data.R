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
library(h3jsr)

# -------------------------------------------------------------
#  Areal Data
# -------------------------------------------------------------
tanzania <- read_sf("data_raw/tanzania/shps/sdr_subnational_data_dhs_2022_lvl_2.shp")
st_crs(tanzania)

st_write_parquet(tanzania, "data/tanzania.parquet")

# -------------------------------------------------------------
# Point data
# -------------------------------------------------------------

kc <- read_sf("data_raw/kingcounty/kc_house.shp")
st_crs(kc)
st_write_parquet(kc, "data/kc_house.parquet")


kc_df <- read.csv("data_raw/kingcounty/kc_house_data.csv")
kc_sf <- st_as_sf(kc_df, coords = c("long", "lat"), crs = 4326)
st_crs(kc_sf)


# -------------------------------------------------------------
# Aggregate point data to H3 grid
# -------------------------------------------------------------

kc$h3 <- point_to_cell(kc, res = 8)

kc_grid <- kc %>% 
  st_drop_geometry() %>% 
  group_by(h3) %>% 
  summarise(price = mean(price))

hex <- cell_to_polygon(kc_grid$h3, simple = FALSE)
kc_grid <- st_sf(kc_grid, geometry = st_as_sfc(hex, crs = 4326))

st_write_parquet(kc_grid, "data/kc_grid.parquet")


# Export data
#st_write(kc, "data/kc_house.geojson", delete_dsn = TRUE)

