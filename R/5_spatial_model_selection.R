# -------------------------------------------------------------
#  SPEC – Introduzione all'Econometria Spaziale
#  2/3 Marzo 2026 – Teacher: Vincenzo Nardelli
# -------------------------------------------------------------

# -------------------------------------------------------------
#  1) Load packages and data
# -------------------------------------------------------------
library(sf)
library(dplyr)
library(sfarrow)
library(spdep)
library(ggplot2)
library(RColorBrewer)
library(tseries)
library(spatialreg)

data <- st_read_parquet("data/italian_provinces.parquet")

data <- data %>% 
  select(den_prov, neet=giovani_non_lavorano_non_studiano, formazione=partecipazione_formazione_continua)

# -------------------------------------------------------------
#  2) Exploratory analysis
# -------------------------------------------------------------
ggplot(data= data) +
  geom_point(aes(x=formazione, y=neet))

cor(data$formazione, data$neet)

ggplot(data = data) +
  geom_sf(aes(fill=neet)) +
  theme_void() +
  scale_fill_gradient(low="white", high="red")

# -------------------------------------------------------------
#  3) Spatial weights and neighbourhood structure
# -------------------------------------------------------------
nb <- poly2nb(data)
listw <- nb2listw(nb)

centroids <- st_coordinates(st_centroid(data))
lines <- nb2lines(nb, coords=centroids, as_sf=TRUE) %>% 
  st_set_crs(st_crs(data))

ggplot(data = data) +
  geom_sf() +
  geom_sf(data=lines) +
  theme_minimal()

# -------------------------------------------------------------
#  4) Spatial autocorrelation and LISA
# -------------------------------------------------------------
data$neet_lag <- lag.listw(listw, data$neet)
moran.test(data$neet, listw)

locm <- localmoran_perm(data$neet, listw)

data <- data %>%
  mutate(neet_lag = lag.listw(listw, data$neet),
         p_value = locm[, 5],
         cluster = case_when(p_value < 0.05 & neet > mean(neet) & neet_lag > mean(neet_lag) ~ "HH", 
                             p_value < 0.05 & neet < mean(neet) & neet_lag < mean(neet_lag) ~ "LL", 
                             p_value < 0.05 & neet > mean(neet) & neet_lag < mean(neet_lag) ~ "HL", 
                             p_value < 0.05 & neet < mean(neet) & neet_lag > mean(neet_lag) ~ "LH"), 
         cluster = factor(cluster, levels = c("HH", "LL", "HL", "LH")))

lisa_palette <- c("#ca0020","#0571b0","#f4a582","#92c5de")

ggplot(data) + 
  geom_sf(aes(fill=cluster), lwd=0.1) + 
  theme_void() + 
  scale_fill_manual(na.value = "lightgray", name="LISA", 
                    values = (lisa_palette)) 

# -------------------------------------------------------------
#  5) OLS model and residual diagnostics
# -------------------------------------------------------------
formula <- neet ~ formazione

ols <- lm(formula, data = data)
summary(ols)
data$predict <- predict(ols)
data$residuals <- residuals(ols)

ggplot(data, aes(x = formazione, y = neet)) +
  geom_point(alpha = 0.7) +
  geom_smooth(method = "lm", color = "red", se = TRUE)

ggplot(data = data) +
  geom_sf(aes(fill = residuals)) +
  scale_fill_gradientn(
    colors = brewer.pal(9, "RdBu"),
    na.value = "grey80"
  )

lm.morantest(ols, listw)

lm.RStests(ols, listw, test=c("RSerr", "RSlag", "adjRSerr", "adjRSlag"))

# -------------------------------------------------------------
#  6) Spatial regression models
# -------------------------------------------------------------
lag<-lagsarlm(formula, listw = listw, data=data)
summary(lag)
impacts(lag, listw = listw, R = 1000, zero.policy = TRUE)

error<-errorsarlm(formula, listw = listw, data=data)
summary(error)

sarma <- sacsarlm(formula, listw = listw, data = data)
summary(sarma)

impacts(sarma, listw = listw, R = 1000, zero.policy = TRUE)