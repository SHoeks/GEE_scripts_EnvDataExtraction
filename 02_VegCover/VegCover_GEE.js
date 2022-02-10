// This script downloads the required VegCover (GLCF) data (in tif format) to be processed later in R
// Import unique xy locations (created using 00_Utilities/csv_to_shapefile.R)
print(table)

// Function for buffering a feature, using the buffer_size
var BufferFeature = function(f) {
  f = ee.Feature(f);
  var buffer_size = f.get('buffer_size');
  return f.buffer(buffer_size);   
};
var BufferFeaturesByDistance = function(fc, buffer_size) {
  var SetBufferSize = function(f) {
    return f.set({'buffer_size': buffer_size});
  };
  return table.map(SetBufferSize).map(BufferFeature);
};

// Execute buffer function, make sure buffer value is large as largest HR*2
var buffered = BufferFeaturesByDistance(table, 30000);

// Load data set included in GLCF (2000)
var dataset1 = ee.ImageCollection('GLCF/GLS_TCC')
                  .filter(ee.Filter.date('2000-01-01', '2000-12-01'))
                  .select('tree_canopy_cover')
                  .filterBounds(buffered)
                  .max();

// Load data set included in GLCF (2005)
var dataset2 = ee.ImageCollection('GLCF/GLS_TCC')
                  .filter(ee.Filter.date('2005-01-01', '2005-12-01'))
                  .select('tree_canopy_cover')
                  .max();

// Load data set included in GLCF (2010)                  
var dataset3 = ee.ImageCollection('GLCF/GLS_TCC')
                .filter(ee.Filter.date('2010-01-01', '2010-12-01'))
                .select('tree_canopy_cover')
                .max();
                

// Function to make the Image Collection
var colFunc = function(buffered) {
  var dis = buffered.get("wc_id")
  var clipped = dataset1.clip(buffered).set("wc_id", dis)
  return clipped
}

// Map the FC to an IC 
var imcol = ee.ImageCollection(buffered.map(colFunc))
print(imcol)

// Visualization Vegetation Cover on Map                  
var treeCanopyCoverVis = {min: 0.0,max: 100.0,palette: ['ffffff', 'afce56', '5f9c00', '0e6a00', '003800'],};
Map.addLayer(imcol, treeCanopyCoverVis, 'Tree Canopy Cover');
Map.addLayer(table)


// Get n points
var n_points = buffered.size().int()
print(n_points)
var featlist = buffered.getInfo()["features"]

// Export data dataset1
for (var f= 0; f <= 10000; f = f + 1) {
  try {var feat = ee.Feature(featlist[f]) } catch (error) {break;}
  var dis = feat.get("wc_id")
  var disS = dis.getInfo()
  Export.image.toDrive({
    image: dataset1,
    description: disS.toString()+'_VegCover2000_'+f.toString(),
    folder: "GEE_outputs_new5_1",
    fileNamePrefix: disS.toString()+'_VegCover2000_'+f.toString(),
    region: feat.geometry().bounds(),
    scale: 30
  })
}

// Export data dataset2
for (var f= 0; f <= 10000; f = f + 1) {
  try {var feat = ee.Feature(featlist[f]) } catch (error) {break;}
  var dis = feat.get("wc_id")
  var disS = dis.getInfo()
  Export.image.toDrive({
    image: dataset2,
    description: disS.toString()+'_VegCover2005_'+f.toString(),
    folder: "GEE_outputs_new5_1",
    fileNamePrefix: disS.toString()+'_VegCover2005_'+f.toString(),
    region: feat.geometry().bounds(),
    scale: 30
  })
}

// Export data dataset3
for (var f= 0; f <= 10000; f = f + 1) {
  try {var feat = ee.Feature(featlist[f]) } catch (error) {break;}
  var dis = feat.get("wc_id")
  var disS = dis.getInfo()
  Export.image.toDrive({
    image: dataset3,
    description: disS.toString()+'_VegCover2010_'+f.toString(),
    folder: "GEE_outputs_new5_1",
    fileNamePrefix: disS.toString()+'_VegCover2010_'+f.toString(),
    region: feat.geometry().bounds(),
    scale: 30
  })
}

