# VOT 2014: Car Exercise

### Youngwook Paul Kwon, UC Berkeley

## Introduction

It was more fun than I expected and many things to think about. The input images of a moving vehicle are from the 2014 Visual Object Tracking Challenge (http://www.votchallenge.net/vot2014/).  I tried to answer the original and the most obvious question: "where is the vehicle given its location in the first frame?." I will also discuss about "what is the pixel-level segmentation of the car in each frame?."

<center> <img src="car\00000145.jpg" style="width:450px;"/> <img src="car\00000228.jpg" style="width:450px;"/> </center>

## Report

Please see [report.pdf](report.pdf) for detailed information.  Note that the report pdf includes animations. If animations do not work, please let me know.

## Folders

`car` : Input images and ground truth.
`code` : Source codes. You can run `optical_multiple_frame.m` in MATLAB.
`output` : Output images will be saved in this folder. Sub folders are for more visulization. You can ingnore them fow now.
`readme.md` : This file.
`report.pdf` : My report.


## Some results for teaser

### Optical flows
<center> <img src="fig/flow5.png" style="width:500px;"/> </center>

### Weighted averaged image, `Palette` 
<center> <img src="fig/object.gif"/> </center>
<center> <img src="https://github.com/ywpkwon/vot2014/blob/master/fig/object.gif"/> </center>
![asdf](https://github.com/ywpkwon/vot2014/blob/master/fig/flow1.png)
<center> ![](fig/object.gif) </center>

### Object probability map
This map represents how likely a pixel would be a part of target object. This map is just for visualization and not used to conclude bounding boxes. I expect to improve final bounding boxes by using this information.
<center> <img src="fig\prob_map.png" style="width:900px;"/> </center>
<center> ![asdf](fig\prob.gif) </center>
<center> ![asdf](fig\prob_embed.gif) </center>

## Result
Red and blue bounding boxes represents ground truth and mine, respectively. 
<center> ![asdf](fig\result.gif) </center>








