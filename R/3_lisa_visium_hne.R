# -------------------------------------------------------------
#  SPEC – Introduzione all'Econometria Spaziale
#  2/3 Marzo 2026 – Teacher: Vincenzo Nardelli
# -------------------------------------------------------------
#  LISA (Local Moran) on Visium HNE
#  Generates spatial weights on POINTS (kNN) and runs:
#   - Global Moran's I (analytical + Monte-Carlo)
#   - Local Moran's I (LISA) + cluster map
# -------------------------------------------------------------

library(sf)
library(sfarrow)
library(spdep)
library(dplyr)
library(ggplot2)
set.seed(123)

# -------------------------------------------------------------
#  1) Read GeoParquet exported from Python
# -------------------------------------------------------------

hne <- st_read_parquet("data/visium_hne_points.parquet")
hne$logResp18 <- log1p(hne$Resp18)
y <- hne$logResp18
# -------------------------------------------------------------
#  2) Exploratory visualisations (map + histogram)
# -------------------------------------------------------------

ggplot(hne) +
  geom_sf(aes(color = Resp18), size = 1.1, alpha = 0.9) +
  theme_minimal()

# -------------------------------------------------------------
#  3) Construct spatial weights – kNN (POINT data)
# -------------------------------------------------------------

coords <- st_coordinates(hne)
k <- 8

nb_knn <- knn2nb(knearneigh(coords, k = k))
lw_knn <- nb2listw(nb_knn, style = "W", zero.policy = TRUE)

# -------------------------------------------------------------
#  3b) Visualise the spatial network
# -------------------------------------------------------------

lines <- nb2lines(nb_knn, coords = coords, as_sf = TRUE) %>%
  st_set_crs(st_crs(hne))

ggplot() +
  geom_sf(data = lines, color = "grey25", linewidth = 0.35, alpha = 0.7) +
  geom_sf(data = hne, color = "grey10", size = 0.5, alpha = 0.7) +
  theme_minimal()

# -------------------------------------------------------------
#  4) Global Moran's I (standard & Monte‑Carlo)
# -------------------------------------------------------------

global_moran <- moran.test(y, lw_knn, zero.policy = TRUE)
print(global_moran)

global_moran_mc <- moran.mc(y, lw_knn, nsim = 999, zero.policy = TRUE)
print(global_moran_mc)

# -------------------------------------------------------------
#  5) Local Moran's I (LISA) and cluster classification
# -------------------------------------------------------------

lisa <- localmoran_perm(y, lw_knn, nsim = 999, zero.policy = TRUE)

hne$q <- lisa[, 5]
hne$lisa_cluster <- as.character(attr(lisa, "quadr")$mean)
hne$z_y <- as.numeric(scale(y))
hne$lag_z_y <- lag.listw(lw_knn, hne$z_y, zero.policy = TRUE)

hne <- hne %>%
  mutate(lisa_cluster = ifelse(q < 0.05, lisa_cluster, "Not significant"))

ggplot(hne) +
  geom_sf(aes(color = lisa_cluster), size = 1.1, alpha = 0.9) +
  scale_color_manual(
    values = c(
      "High-High" = "#B2182B",
      "Low-Low" = "#2166AC",
      "High-Low" = "#EF8A62",
      "Low-High" = "#67A9CF",
      "Not significant" = "grey75",
      "Missing" = "grey92"
    )
  ) +
  labs(color = "LISA cluster") +
  theme_minimal()

