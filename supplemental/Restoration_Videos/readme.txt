* "Videos" folder contains 14 videos, one for each of the videos listed in Table 1 of the paper.

* Each video is a collage of the following 9 videos
	- (1) Input Video
	- (2) A Ground Truth video showing the undistorted static background 
	- Outputs of restoration methods (3)DL (5)LWB (5)SBR-RPCA.   
	- Outputs of the methods we propose (6)CS (7)PEOF (8)CS+PEOF
	- We also tried supplementing our "CS+PEOF" methods with an RPCA stage. The video is shown in (9)CS+PEOF+RPCA.
	  As mentioned in the paper, we could remove the spatio-temporal noisy artifacts from the video but the visual and numerical quality of the mean image improved only marginally.


*Each video is of 6 seconds.
	-First 2 second segment shows the restoration video output of each method
	-The next 2 second segment shows the mean of each restoration method
	-The next 2 seconds highlights the local SSIM errors of restoration result of each method wrt Ground Truth. The video segment is created in the following manner
		- 0.7*RestoredImage + 0.3*(1-SSIM_Map).*Red_Color. Hence, wherever the ssim values are lower, one will see those regions getting highlighted with brighter red color.
		- You can observe that the current state of the art methods do not reconstruct the background correctly. Particularly, SBR-RPCA gives a very stable video, but is significantly distorted wrt the
		  ground truth.