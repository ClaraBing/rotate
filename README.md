# Rotate
**Planar rotation**  
*Input*: image name, output filename, angle (in radius)  

*Output*: square image containing the rotated image w/ all other pixles padded by the image mean  
- e.g. 000000.JPEG is the original image, while 000000\_rotated*k*.JPEG are images rotated k \* pi/4 counter-clockwise and 000000\_rotated\_neg.JPEG is rotation with -pi/4.

**Perspective change**  
*Input*: image name, output filename, 3 rotation angles (around x/y/z-axis).  
*Output*: image seen from a changed perspective; pixels outside the image are padded w/ image mean.  
- e.g. 000000.JPEG is the original image; 000000\_ps1.JPEG is rotation around x-axis only, 000000\_ps2.JPEG is rotation around y-axis only, 00000\0_ps3.JPEG is rotation around both x and y axis. 000000\_ps4.JPEG is rotation around z-axis, which should look like planar rotation.  000000\_ps\*\_round.JPEG are images obtained in a slightly different manner (i.e. torch.round instead of torch.floor for calculating new pixel coordinates).  

**ToDo**   
- There are some fine lines in image 000000\_ps2.JPEG and 000000\_ps2\_round.JPEG.
