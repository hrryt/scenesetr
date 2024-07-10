greenland_bed <- list.files("../3d/greenland_bed", full.names = TRUE)
greenland_bed <- lapply(greenland_bed, stars::read_stars)
greenland_bed <- do.call(stars::st_mosaic, greenland_bed)
names(greenland_bed) <- "relief"
greenland_bed <- stars::st_downsample(greenland_bed, 20)
greenland_bed <- greenland_bed * 1e-3

usethis::use_data(greenland_bed, overwrite = TRUE)

greenland_ice <- list.files("../3d/greenland_ice", full.names = TRUE)
greenland_ice <- lapply(greenland_ice, stars::read_stars)
greenland_ice <- do.call(stars::st_mosaic, greenland_ice)
names(greenland_ice) <- "relief"
greenland_ice <- stars::st_downsample(greenland_ice, 20)
greenland_ice <- greenland_ice * 1e-3

greenland_ice$relief[greenland_ice$relief < 0] <- NA
greenland_ice$relief[(greenland_ice - greenland_bed)$relief <= 0] <- NA
greenland_ice$relief[343, ] <- NA
greenland_ice <- greenland_ice[, 1:1200, 1:400]

usethis::use_data(greenland_ice, overwrite = TRUE)
