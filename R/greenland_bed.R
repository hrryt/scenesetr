#' Greenland Relief Data
#' 
#' A subset of data from the ETOPO 2022 15 Arc-Second Global Relief Model. 
#' `greenland_bed` is bed relief and `greenland_ice` is ice surface relief.
#' 
#' @source <https://data.noaa.gov/onestop/collections/details/986f93b8-0a07-4e44-a2bc-bdee3c02fd5a>
#' 
#' [stars::st_downsample()] was performed with `n = 20` and relief in meters was 
#' converted to kilometers.
#' 
#' NOAA National Centers for Environmental Information. 
#' 2022: ETOPO 2022 15 Arc-Second Global Relief Model. 
#' NOAA National Centers for Environmental Information. 
#' DOI: 10.25921/fd45-gt74. Accessed 01/03/2024. 
"greenland_bed"

#' @rdname greenland_bed
"greenland_ice"