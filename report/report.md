# Uber ATC assignment: Car Exercise
### Youngwook Paul Kwon, UC Berkeley

## Introduction

It was more fun than I expected and many things to think about. The input images of a moving vehicle are from the 2014 Visual Object Tracking Challenge (http://www.votchallenge.net/vot2014/).  I tried to answer the original and the most obvious question: "where is the vehicle given its location in the first frame?." I will also discuss about "what is the pixel-level segmentation of the car in each frame?."

<center> <img src="fig\00000145.jpg" style="width:450px;"/> <img src="fig\00000228.jpg" style="width:450px;"/> </center>


## Implementation
 I implemented a few schemes to improve performance. I will explain each in a separate section. Please understand that I implemented these using MATLAB for fast prototyping.  I tried different things and had no time to convert codes into Python. I can guarantee that I can convert codes into Python. I did not use any special libraries for this submission.

For simplicity, I denote an image and a bounding box at video `frame i` as $$$I_i$$$ and $$$F_i$$$, respectively. In other words, we can rephrase the question as: when we have a set of images $$$I_i$$$ and $$$F_1$$$, what are $$$F_i $$$s?

## Algorithm

### 1. Local sub-patch matching using Euclidean distance.

Because the target object (the vehicle) changes in its size and perspective, template matching of entire frame may not good. So I determined to find local level matching. I sampled 200 points (subdivided into 20 in $$$x$$$ and 10 in $$$y$$$) within $$$F_i$$$, collected 15x15 sub-patches centered at them in $$$I_i$$$, and did template matching in $$$I_{i+1}$$$. For implementation simplicity, I just used Euclidean distance of RGB color. Using LAB color space and Normalized cross correlation measure would improve performance. For calculation efficiency in finding match of a sub-patch centered $$$(x,y)$$$ in $$$I_i$$$, I first searched it in $$$[x-30, x+30], [y-30, y+30]$$$ range in $$$I_{i+1}$$$ with stride 3. Once it returns the nearest neighbor position $$$(x', y')$$$, I refined the position by re-searching in $$$[x'-5, x'+5]$$$ and $$$[y'-5, y'+5]$$$ with stride 1.

An example of matches (optical flows) is shown below.
<center> <img src="fig\example.png" alt="Drawing" style="width:600px;"/> </center>

### 2. Affine transformation using RANSAC

I assumed the vehicle of `frame i+1` can be approximated with the vehicle of `frame i` and affine transformation $$$T_i$$$. Let say, $$$ I_i$$$ is the i-th image in `frame_i`, then $$$ I_{i+1} \approx  T[I_i] $$$. ** Note that even though an affine transformation $$$T$$$ is $$$3\times3$$$ matrix, for simplicity I will denote $$$T[I]$$$ as a warped image from image $$$I$$$ by $$$T$$$, and similarly, $$$T[(x,y)]$$$ as a remapped point from $$$(x,y)$$$ by $$$T$$$. 

Now we have a set of flows, i.e., a set of points $$$P_i$$$ in $$$ I_i$$$and its correspondences $$$P_{i+1}$$$ in $$$I_{i+1}$$$, and we want to know $$$T_i$$$. I used RANSAC algorithm. I will skip the details of RANSAC. The beauty of it is that it can give you a model (transformation $$$T_i$$$) that most of data ($$$P_i$$$ and $$$P_{i+1}$$$) satisfies even when the data is contaminated by *outliers*. 

An example is shown below. Red optical flows show the *inlier* flows (i.e., the ones who agree with $$$T_i$$$).
<center> <img src="fig\flow1.png" alt="Drawing" style="width:600px;"/> </center>


### 3. Interaction with more future frames

Finding matches and transformation only with next frame may not enough in that (1) since two images are very similar, they provide too many false inliers, and (2) since pixel locations are all integers, subtle flow within 1 pixel will lose its floating number. So I calculate matches and transformations from `frame_i` to `frame i+1`, `frame i+2`, `frame i+3`, `frame i+4`, `frame i+5`. An example is shown below. After I scaled the flows (e.g., 1/5*(flow to `frame i+5`)), I concluded overall $$$T_i$$$ using RANSAC as discussed in the previous section.

<center> <img src="fig\flow5.png" alt="Drawing" style="width:600px;"/> </center>

### 4. Overcoming occlusions using `Palette`

Because this algorithm basically relies on sub-patch matching, once some salient occluding object appears, the occluding object may generate dominant matches. Then the algorithm will track the occluding object instead of the vehicle. For this reason, finding matches only from $$$I_i$$$ is not enough. Regardless of a temporal appearance at `frame i`, the algorithm need to *remember* the look of the vehicle. 

For this purpose, I defined `palette`, which is nothing but a weighted average of vehicle. Specifically, palette $$$P_i$$$ at `frame i` is defined as follow:
$$ P_{i-1} = \alpha \cdot \: T_{i-1}[P_{i-1}] + (1-\alpha) \cdot I_i$$
where  $$$0 \leq \alpha \leq 1$$$, and $$$T[I]$$$ means applying transformation $$$T$$$ to image $$$I$$$.

Higher $$$\alpha$$$ value relies more on the current appearance at `frame_i`, and lower value relies more on the historical appearance. I show an example below when $$$alpha=0.2$$$. One can see that temporally changing background is blurred while the appearance of vehicle is maintained, even when the vehicle passes trees. 
<center> ![asdf](fig\object.gif) </center>


### 5. Refined transformation

So now, when I find optical flows at `frame i`, there are two steps. Firstly, I find optical flows from $$$P_i$$$ (instead of $$$I_i$$$) to $$$\{I_{i+1}\text{~}I_{i+5}\}$$$ and calculate rough transformation $$$T_i^{rough}$$$, as described earlier. A good thing is that the flows are now less affected by temporal occlusion. A bad thing is that since $$$P_i$$$ is an averaged appearance, optical flows maybe not accurate. For this reason, as second step, I re-search matches from the original $$$I_i$$$ (instead of $$$ P_i $$$) to $$$I_{i+1}\text{~}I_{i+5}$$$. This time I search only within a tiny region that $$$T_i^{rough}$$$ points. Specifically, let say a sample point is $$$(x,y)$$$. I only search its corresponding patch, in $$$I_{i+1}$$$, within a region ($$$\pm 5$$$ in x and y) centered at $$$T_i^{rough}[(x,y)]$$$.

### 6. Object probability map
Now I am going to discuss the second question, "what is the pixel-level segmentation of the car in each frame?." Even though I did not fully investigated this, it is very interesting to think. In section 1-3, I discuss how to find matches and calculate transformation using RANSAC (interacting with `frame i+1` to `frame i+5`.) I collected inliers (among sampling points), and made density map of inliers, $$$D_i$$$, titled `probability map`. Because probability map reflects which pixels agree with $$$T_i$$$, one can regard high probability region as one object. Note that if we can increase the resolution of sampling grid, we can have higher resolution of probability map.
<center> <img src="fig\prob_map.png" style="width:900px;"/> </center>


Probability maps are shown below. I expect we can generate vehicle segmentation by considering pixel color and probability map together (e.g., maybe normalized cut?). This will also increase detection performance.
<center> ![asdf](fig\prob.gif) </center>
<center> ![asdf](fig\prob_embed.gif) </center>

You can see that when trees occludes vehicle, probability maps do not include trees.

## Result

Here is the result video (actually GIF file!).
<center> ![asdf](fig\result.gif) </center>

Note that I did not exploit the probability maps (in section 6). If I exploit them in a smart way, I think I can refine bounding boxes. Overall, this assignment was very fun to do. 

Thanks for reading :)








