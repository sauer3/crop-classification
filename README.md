# Classifying Crop Type using Satellite Imagery

## Overview
One of the United Nations sustainable development goals is “zero hunger by 2030.” Hunger and malnutrition remain a significant barrier to development in Africa. Collecting accurate data is critical for monitoring agricultural growth and improving food security. I will be using data from a Zindi challenge, which is an African data science platform that focuses on using data science for social benefit. 

This project is a stepping stone to more advanced predictions such as crop yield prediction and predicted food security under future climate change scenarios which I am interested in doing for my final project. 

## Goals
The objective of this project is to create a multi-class supervised classification model to label fields by crop type using Sentinel-2 satellite imagery. The fields in the training set are along the Orange River, a major agricultural region in South Africa that has been stricken by drought in recent years. The end result will be a map of classified crop types for the agricultural region along the Orange river. 

## Concerns
I’m not sure if this dataset is appropriate to use with postgres. Is it ok if I use a geographic version of postgres? (https://postgis.net/)
I worried the scope is too ambitious for my first classification project. Not sure what my MVP would be. MVP is predicting farmland vs. non farmland

## Data
There are 7 crop types present in the fields:

1. Cotton
2. Dates
3. Grass
4. Lucern
5. Maize
6. Pecan
7. Vacant
8. Vineyard
9. Vineyard & Pecan ("Intercrop")

## Files included in the dataset:
- Orange River Climate: Useful background information
- Orange River Crop Grown Stages: Useful background information
- Train.zip: shapefile containing all of the fields in the training dataset. This is the dataset that you will use to train your model.
- Test.zip: shapefile containing all of the fields in the test dataset. 
- Crop_id_list.csv: List of all the unique crops and their Crop IDs
- Satellite images tile 1 are the 11 files named as YYYY-MM-DD.zip: These are Sentinel-2 satellite data captured on the date indicated in the file name. These files are in SENTINEL-SAFE format, including image data in JPEG2000 format, quality indicators (e.g. defective pixels mask), auxiliary data and metadata. This includes all bands and TCI. Each image contains 90% fields in both the training and test set.
- Satellite images tile 2 are the 11 files named as YYYY-MM-DD-JFP.zip: These are Sentinel-2 satellite data captured on the date indicated in the file name. These files are in SENTINEL-SAFE format, including image data in JPEG2000 format, quality indicators (e.g. defective pixels mask), auxiliary data and metadata. This includes all bands and TCI. Each image contains the remaining 10% of fields in both the training and test set.
- The two tiles make up the entire scene. 90% of the fields are in tile 1 and the remaining 10% of the fields are in tile 2.
