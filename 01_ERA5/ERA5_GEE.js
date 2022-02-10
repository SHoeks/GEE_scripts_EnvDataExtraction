// This script downloads the required ERA5 data to be processed later in R
// Import unique xy locations (created using 00_Utilities/csv_to_shapefile.R)
print(table)

// Function for zero padding months
function pad(n, width, z) {
  z = z || '0';
  n = n + '';
  return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
}

// Loop over available years
for (var year= 1979; year <= 2006; year = year + 1) {

  // Init data string
  var data_str = "ECMWF/ERA5/MONTHLY/";
  var data_str = data_str.concat(year.toString());
  
  // Init output string
  var out_str = "ERA5_new_";
  var out_str = out_str.concat(year.toString());
  
  // Loop over months
  for (var i= 1; i <= 12; i = i + 1) {
  
    // Create data string
    var month = pad(i,2)
    var data_str2 = data_str.concat(month.toString());
    print(data_str2)
    
    // Create output name string
    var out_str2 = out_str.concat(month.toString());
    print(out_str2)
    
    // Set data
    var ERA5 = ee.Image(data_str2)
    
    // Use reduces to sample variable at locations p
    var p_sampled = ERA5.reduceRegions({collection: table,reducer: ee.Reducer.mean(),scale: 40,});
  
    // Export p_sampled
    Export.table.toDrive({collection: p_sampled,folder: 'GEE_outputs_new5_1',description: out_str2,fileFormat: 'csv'});
    
  }
  
}


