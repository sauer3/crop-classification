## This script does basic GIS manipulations for getting the crop classifications 
## in the right format for modeling

library(raster)
library(rgeos)
library(rgdal)
library(maptools)

# create multiband raster and spatial points ------------------------------

# load orange river dataset and reproject
dir <- "/Users/AuerPower/Metis/git/crop-classification/data/imagery/tile1/S2A_MSIL1C_20170101T082332_N0204_R121_T34JEP_20170101T084543_SAFE/GRANULE/L1C_T34JEP_A007983_20170101T084543/IMG_DATA/"

orange_river <- readOGR("/Users/AuerPower/Metis/git/crop-classification/data/train", "train")
crs(orange_river)
rgb <- stack("/Users/AuerPower/Metis/git/crop-classification/work_flow/RGB.tiff")

orange_river <- spTransform(orange_river,crs(rgb))
writeOGR(orange_river, '/Users/AuerPower/Metis/git/crop-classification/data/intermediate', 'orange_river_prj', driver = "ESRI Shapefile")

ext <- extent(c(571678.5, 590107.4, 6816898, 6833887))
#ext <- drawExtent()
# class       : Extent 
# xmin        : 571678.5 
# xmax        : 590107.4 
# ymin        : 6816898 
# ymax        : 6833887 

#orange_river_crop <- crop(orange_river, ext)

#writeOGR(orange_river_crop, '/Users/AuerPower/Metis/git/crop-classification/data/intermediate', 'crop_ext_prj', driver = "ESRI Shapefile")
#plot(rgb[[1]])
#plot(orange_river)

#crop_rgb <- crop(rgb, orange_river_crop)
#boxes <- readOGR('/Users/AuerPower/Metis/git/crop-classification/data/intermediate', 'selected_orange_river_bboxes')

### Import imagery bands for raster
img <- stack('/Users/AuerPower/Metis/git/crop-classification/data/intermediate/veg_indices.tiff')
plot(img[[5]])
plot(orange_river, add=TRUE)

### Crop imagery and orange river to match
orange_river <- crop(orange_river, img)
img <- crop(img, orange_river)
#writeOGR(orange_river, '/Users/AuerPower/Metis/git/crop-classification/data/intermediate', 'orange_river_crop_img', driver = "ESRI Shapefile")
writeRaster(img, '/Users/AuerPower/Metis/git/crop-classification/data/intermediate/veg_indices_crop.tiff')


# sampling ----------------------------------------------------------------

orange_river <- readOGR('/Users/AuerPower/Metis/git/crop-classification/data/intermediate', 'orange_river_crop_img')
img <- stack('/Users/AuerPower/Metis/git/crop-classification/data/intermediate/veg_indices_crop.tiff')

## convert shape to raster
orange_river_ras <- rasterize(orange_river, img[[4]], 'Crop_Id_Ne')
orange_river_region <- rasterize(orange_river, img[[4]], 'Field_Id')


## convert raster to points
orange_river_points <- rasterToPoints(orange_river_ras, fun=NULL, spatial=TRUE)
orange_river_region_points <- rasterToPoints(orange_river_region, fun=NULL, spatial=TRUE)
writeOGR(orange_river_region_points, '/Users/AuerPower/Metis/git/crop-classification/data/intermediate', 
         'fieldID_points', driver = "ESRI Shapefile")

### Extract img raster values to crop polygons
#orange_river_buff <- buffer(orange_river, width=20)

### create points within polygons
#samples <- spsample(orange_river_buff , n=10000, "random")
#points <- SpatialPointsDataFrame(coords, data=coord_df, proj4string=crs(orange_river))

### extract values from crop polygon and img bands
#samples_img <- extract(img, samples, method='simple', sp=TRUE)
samples_img <- extract(img, orange_river_points, method='bilinear', sp=TRUE)
samples_img_df <- as.data.frame(samples_img, xy=TRUE)

writeOGR(samples_img, '/Users/AuerPower/Metis/git/crop-classification/data/intermediate', 'samples', driver = "ESRI Shapefile" , overwrite_layer = TRUE)
write.csv(samples_img_df, '/Users/AuerPower/Metis/git/crop-classification/data/intermediate/samples_df.csv')

# sampling v2 -------------------------------------------------------------

orange_river <- readOGR('/Users/AuerPower/Metis/git/crop-classification/data/intermediate', 'orange_river_crop_img')
orange_river_boxes <- readOGR('/Users/AuerPower/Metis/git/crop-classification/data/intermediate', 'selected_orange_river_bboxes')

paths <- list.files('/Users/AuerPower/Metis/git/crop-classification/data/intermediate/seasonal_veg', 
                    full.names = TRUE)
img <- stack(paths)

img <- crop(img, ext)
writeRaster(img[[1]], "/Users/AuerPower/Metis/git/crop-classification/data/intermediate/template_img_ras.tiff")
## convert shape to raster
orange_river_ras <- rasterize(orange_river, img[[1]], 'Crop_Id_Ne')
orange_river_region <- rasterize(orange_river, img[[1]], 'Field_Id')

## convert raster to points
orange_river_points <- rasterToPoints(orange_river_ras, fun=NULL, spatial=TRUE)
orange_river_region_points <- rasterToPoints(orange_river_region, fun=NULL, spatial=TRUE)
#orange_river_points <- merge(orange_river_points, orange_river_region_points)
writeOGR(orange_river_region_points, '/Users/AuerPower/Metis/git/crop-classification/data/intermediate', 
         'fieldID_points', driver = "ESRI Shapefile", overwrite_layer = TRUE)

### extract values from crop polygon and img bands
samples_img <- extract(img, orange_river_points, method='bilinear', sp=TRUE)
 
#writeOGR(samples_img, '/Users/AuerPower/Metis/git/crop-classification/data/intermediate', 'samples', driver = "ESRI Shapefile" , overwrite_layer = TRUE)
samples_img <- readOGR('/Users/AuerPower/Metis/git/crop-classification/data/intermediate', 'samples')
orange_river_region_points <-readOGR('/Users/AuerPower/Metis/git/crop-classification/data/intermediate', 
                                     'fieldID_points')
names(samples_img)[1] <- 'crop'
#names(orange_river_region_points)[1] <- 'field_ID'
## extract to boxes
extract_box <- crop(samples_img, ext)
writeOGR(extract_box, '/Users/AuerPower/Metis/git/crop-classification/data/intermediate', 'samples_subset', driver = "ESRI Shapefile" , overwrite_layer = TRUE)
field_id_box <- crop(orange_river_region_points, ext)

samples_merge <- merge(samples_img, orange_river_region_points)

writeOGR(field_id_box, '/Users/AuerPower/Metis/git/crop-classification/data/intermediate', 
         'fieldID_subset', driver = "ESRI Shapefile", overwrite_layer = TRUE)

orange_crop <- crop(orange_river, ext)
writeOGR(orange_crop, '/Users/AuerPower/Metis/git/crop-classification/data/intermediate', 
         'orange_river_crop_ext', driver = "ESRI Shapefile", overwrite_layer = TRUE)


# visualizing model results -----------------------------------------------
errors <- stack('/Users/AuerPower/Metis/git/crop-classification/data/intermediate/raster_results/rasterized_error.tiff')
field_polygons <- readOGR('/Users/AuerPower/Metis/git/crop-classification/data/intermediate/', 'test_train_subset')
prediction_ras <- raster('/Users/AuerPower/Metis/git/crop-classification/data/intermediate/raster_results/rasterized_prediction.tiff')

Mode <- function(x, na.rm = TRUE) {
  if(na.rm){
    x = x[!is.na(x)]
  }
  
  ux <- unique(x)
  return(ux[which.max(tabulate(match(x, ux)))])
}

# drop train polygons
field_polygons = field_polygons[field_polygons$split=='test',]
aggregate_prediction <- extract(prediction_ras, field_polygons, fun=Mode, sp=TRUE)

#aggregate_prediction <- aggregate_prediction[!is.na(aggregate_prediction$diff),]
#aggregate_prediction <- aggregate_prediction[c(1,2,3,4,6,7,8)]
aggregate_prediction$vinyard <- sub(8, 1, aggregate_prediction$Crop_Id_Ne)
aggregate_prediction$vinyard <- sub(7, 0, aggregate_prediction$vinyard)
aggregate_prediction$vinyard <- sub(6, 0, aggregate_prediction$vinyard)
aggregate_prediction$vinyard <- sub(5, 0, aggregate_prediction$vinyard)
aggregate_prediction$vinyard <- sub(4, 0, aggregate_prediction$vinyard)
aggregate_prediction$vinyard <- sub(3, 0, aggregate_prediction$vinyard)
aggregate_prediction$vinyard <- sub(2, 0, aggregate_prediction$vinyard)
aggregate_prediction$vinyard <- sub(9, 0, aggregate_prediction$vinyard)
aggregate_prediction$vinyard <- as.numeric(aggregate_prediction$vinyard)
aggregate_prediction$diff <- aggregate_prediction$vinyard - aggregate_prediction$rasterized_prediction

writeOGR(aggregate_prediction, '/Users/AuerPower/Metis/git/crop-classification/data/intermediate', 
         'prediction_polygons', driver = "ESRI Shapefile", overwrite_layer = TRUE)
