About the BitmapDataCollecionSamplerHaxe.hx version
-----------------------------------------------
com.flashartofwar.BitmapDataCollecionSamplerHaxe

To get started, the haxelib.hxml will compile a SWC for you with the above file, which you need have for running under the main AS class under the BitmapDataCollectionSamplerHaxe.as version.

The fork contains the Haxe-i-fied version of BitmapDataCollectionSampler that involves scrolling a bunch of bitmap-datas stored in Alchemy memory. 

The result is a consistent framerate throughout, regardless of how far in/out you're scrolling within the list, the search time is always at "0(1)" time. This is achieved by simply moving the ByteArray memory position pointer to match the scrolling value, and calling bitmapData.setPixels(rect, byteArray) to render the bytes. I get 61 fps consistently, with absolutely no drops.

In the standard copyPixels() version, codes had to do a "Olog-n" search to find the target location from the starting location. So, the further you go down the list, the longer the search time would get. Iterating from the last known position index won't work either if in the worse case scenerio, the distance travelled per tick is of extremely large (skip here/there) values. For large list, this means iterating through many indexes to find the current index.

The Haxe Alchemy version has no limit of the number of n-entries as far as performance is concerned. However, memory usage/storage can be extremely high and time-consuming at the beginning, including storing all pixel data found in the images. 

The ideal case for using the Haxe Alchemy version is when your server or developer has already pre-processed the images and fitted them into the actual viewing size during scrolling. Also, for images to be scrolled horizontally, the images had to be read in a translated (rotate 90 degrees) fashion into memory, and the bitmap & bitmapData itself had to be rotated 90 degrees and the bitmap re-positioned. If the images loaded in were already rotated, these translations could be avoided on the Flash-side, improving startup time.