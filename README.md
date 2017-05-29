# Rotate
**Planar rotation**  
*Input*: image name, output filename, angle (in radius)  

*Output*: square image containing the rotated image w/ all other pixles padded by the image mean  
- e.g. 000000.JPEG is the original image, while 000000\_rotated*k*.JPEG are images rotated k \* pi/4 counter-clockwise and 000000\_rotated\_neg.JPEG is rotation with -pi/4.
  
**ToDo**  
- Perspective change (i.e. rotation around arbitrary axes)  

