# -------------------------------------------------------------
#  SPEC – Introduzione all'Econometria Spaziale
#  2/3 Marzo 2026 – Teacher: Vincenzo Nardelli
# -------------------------------------------------------------

# -------------------------------------------------------------
#  0) Load required packages
# -------------------------------------------------------------
library(sf)          # spatial vector handling
library(sfarrow)
library(spdep)       # spatial dependence functions
library(dplyr)       # data manipulation
library(ggplot2)     # plotting
set.seed(123)  # reproducibility

# -------------------------------------------------------------
#  1) Read data
# -------------------------------------------------------------
kc <- st_read_parquet("data/kc_grid.parquet")
kc$logprice <- log(kc$price)
# -------------------------------------------------------------
#  2) Exploratory visualisations (map + histogram)
# -------------------------------------------------------------
# 2a) Choropleth of fertility rate
ggplot(kc) +
  geom_sf(aes(fill = logprice)) +
  scale_fill_gradient(name = "logprice",
                      low = "#fff7bc", high = "#d7301f")

# -------------------------------------------------------------
#  3) Construct spatial weights – Queen contiguity
# -------------------------------------------------------------
# Queen adjacency (share edge or vertex)
nb_q  <- poly2nb(kc, queen = TRUE)
lw_q  <- nb2listw(nb_q, style = "W", zero.policy = TRUE)

# -------------------------------------------------------------
#  3b) Visualise the spatial network
# -------------------------------------------------------------
centroids <- st_coordinates(st_centroid(kc))
lines <- nb2lines(nb_q, coords = centroids, as_sf = TRUE) %>% 
  st_set_crs(st_crs(kc))

ggplot(kc) +
  geom_sf(fill = "grey95", color = "grey75", linewidth = 0.15) +
  geom_sf(data = lines, color = "grey25", linewidth = 0.45, alpha = 0.85) +
  theme_minimal()

# -------------------------------------------------------------
#  4) Global Moran's I (standard & Monte‑Carlo)
# -------------------------------------------------------------
y   <- kc$logprice

# Analytical test
global_moran <- moran.test(y, lw_q)
print(global_moran)

# Monte‑Carlo approximation
global_moran_mc <- moran.mc(y, lw_q, nsim = 999)
print(global_moran_mc)

# -------------------------------------------------------------
#  5) Local Moran's I (LISA) and cluster classification
# -------------------------------------------------------------
lisa <- localmoran_perm(y, lw_q, zero.policy = TRUE)

kc$q <- lisa[,5]
kc$lisa_cluster <- as.character(attr(lisa, "quadr")$mean)
kc$z_y       <- as.numeric(scale(y))
kc$lag_z_y   <- lag.listw(lw_q, kc$z_y , zero.policy = TRUE)

kc <- kc %>% 
  mutate(lisa_cluster = ifelse(q < 0.05, lisa_cluster, "Not significant"))

# Plot LISA clusters
ggplot(kc) +
  geom_sf(aes(fill = lisa_cluster)) +
  scale_fill_manual(values = c("High-High" = "#B2182B",
                               "Low-Low"   = "#2166AC",
                               "High-Low"  = "#EF8A62",
                               "Low-High"  = "#67A9CF",
                               "Not significant" = "grey85",
                               "Missing" = "grey92"))

# -------------------------------------------------------------
#  6) Moran scatterplot (showing significant points)
# -------------------------------------------------------------

# Standardised Moran scatterplot with LISA colours
ggplot(kc, aes(x = z_y, y = lag_z_y)) +
  geom_hline(yintercept = 0, color = "grey70", linewidth = 0.4) +
  geom_vline(xintercept = 0, color = "grey70", linewidth = 0.4) +
  geom_point(aes(color = lisa_cluster), size = 2.4, alpha = 0.5) +
  geom_abline(intercept = 0, slope = global_moran_mc$statistic, color = "grey25", linewidth = 0.7) +
  scale_color_manual(values = c("High-High" = "#B2182B",
                                "Low-Low"   = "#2166AC",
                                "High-Low"  = "#EF8A62",
                                "Low-High"  = "#67A9CF",
                                "Not significant" = "grey85")) +
  labs(title = "Moran scatterplot",
       x = "z(Fertility rate)",
       y = "Wz(Fertility rate)",
       color = "LISA cluster") +
  theme_minimal()
