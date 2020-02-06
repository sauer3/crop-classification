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
orange_river_ras = rasterize(orange_river, img[[4]], 'Crop_Id_Ne')

## convert raster to points
orange_river_points <- rasterToPoints(orange_river_ras, fun=NULL, spatial=TRUE)

### Extract img raster values to crop polygons
#orange_river_buff <- buffer(orange_river, width=20)

### create points within polygons
#samples <- spsample(orange_river_buff , n=10000, "random")
#points <- SpatialPointsDataFrame(coords, data=coord_df, proj4string=crs(orange_river))

### extract values from crop polygon and img bands
#samples_img <- extract(img, samples, method='simple', sp=TRUE)
samples_img <- extract(img, orange_river_points, method='simple', sp=TRUE)
samples_img_df <- as.data.frame(samples_img, xy=TRUE)

writeOGR(samples_img, '/Users/AuerPower/Metis/git/crop-classification/data/intermediate', 'samples', driver = "ESRI Shapefile" , overwrite_layer = TRUE)
write.csv(samples_img_df, '/Users/AuerPower/Metis/git/crop-classification/data/intermediate/samples_df.csv')


