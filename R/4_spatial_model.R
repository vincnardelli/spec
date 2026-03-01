# -------------------------------------------------------------
#  SPEC – Introduzione all'Econometria Spaziale
#  2/3 Marzo 2026 – Teacher: Vincenzo Nardelli
# -------------------------------------------------------------

# -------------------------------------------------------------
#  0) Load required packages
# -------------------------------------------------------------
library(sf)          # vector data handling
library(spdep)       # spatial dependence tools
library(spatialreg)  # spatial regression models
library(ggplot2)     # plotting
set.seed(123)        # reproducibility

# --------------------------------------------------------------------
# 1) Read polygons and quick data checks
# --------------------------------------------------------------------
tz <- st_read_parquet("data/tanzania.parquet")


# Summaries of key variables
summary(tz$AHMIGRWEMP)   # migration rate
summary(tz$EDEDUCWSEH)   # education level

# --------------------------------------------------------------------
# 2) Exploratory plots
# --------------------------------------------------------------------
ggplot(data = tz) +
  geom_point(aes(x = EDEDUCWSEH, y = AHMIGRWEMP)) +
  labs(x = "Education", y = "Migration")

ggplot(tz) +
  geom_sf(aes(fill = EDEDUCWSEH)) +
  scale_fill_gradient(name = "Education",
                      low = "#fff7bc", high = "#d7301f")

ggplot(tz) +
  geom_sf(aes(fill = AHMIGRWEMP)) +
  scale_fill_gradient(name = "Migration",
                      low = "#fff7bc", high = "#d7301f")

# --------------------------------------------------------------------
# 3) Baseline OLS regression & residual spatial autocorrelation
# --------------------------------------------------------------------
ols <- lm(AHMIGRWEMP ~ EDEDUCWSEH, data = tz)
summary(ols)

ggplot(data = tz) +
  geom_point(aes(x = EDEDUCWSEH, y = AHMIGRWEMP)) +
  geom_abline(intercept = 11.95, slope = 0.001) +
  labs(x = "Education", y = "Migration") +
  theme_minimal()

## Moran's I on OLS residuals
nb_q <- poly2nb(tz, queen = TRUE)
lw_q <- nb2listw(nb_q, style = "W", zero.policy = TRUE)

moran.test(residuals(ols), lw_q, zero.policy = TRUE)

tz$residual_ols <- residuals(ols)

ggplot(data = tz) +
  geom_point(aes(x = EDEDUCWSEH, y = AHMIGRWEMP, fill = residual_ols),
             shape = 21, color = "black", stroke = 0.5, size = 3) +
  geom_abline(intercept = 11.95, slope = 0.001) +
  labs(x = "Education", y = "Migration") +
  scale_fill_gradient2(name = "Residual OLS",
                       low = "#2b83ba", mid = "white", high = "#d7191c",
                       midpoint = 0) +
  theme_minimal() +
  labs(title = "Linear Regression")


ggplot(tz) +
  geom_sf(aes(fill = residual_ols)) +
  scale_fill_gradient2(name = "Residual Map",
                       low = "#2b83ba", mid = "white", high = "#d7191c",
                       midpoint = 0)

# --------------------------------------------------------------------
# 3) Spatial error model (SEM)
# --------------------------------------------------------------------
# y = Xβ + u ; u = λWu + ε
sar_err <- errorsarlm(AHMIGRWEMP ~ EDEDUCWSEH,
                      data = tz,
                      listw = lw_q)

summary(sar_err)
summary(sar_err, Nagelkerke = TRUE)
