# smooth2voxel
these scripts are used to convert smooth terrain maps into old voxel terrain, useful for restoring old maps that got converted to smooth terrain ~2017
## how2use
the scripts don't have a gui yet so you have to edit the code directly to change the options atm

 1. open the file with smooth terrain that you want to convert in modern studio
 2. get the coordinates of both corners of the area you want to save
 3. put the coordinates in the `saveRegion` option at the top of `save.lua`
 4. run `save.lua` and once it's done it will select an object called `Terrain Data`
 5. save the `Terrain Data` object to an rbxm
 6. open `empty voxel terrain map.rbxl` in a version of studio that supports voxel terrain (i used 2016)
 7. insert the `Terrain Data` model and select it
 8. run `load.lua` and it should load the terrain!

hope ya enjoy, leave any issues on the issues page