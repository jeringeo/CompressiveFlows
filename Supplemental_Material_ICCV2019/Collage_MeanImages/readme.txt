* "Images" folder contains 28 images, two for each of the videos listed in Table 1 of the paper.


Set1 - Naming format : VideoName_Mean_Images.jpg

	* Each image is a collage of the following 9 images
		- (1) Mean of the input Video
		- (2) A Ground Truth image showing the undistorted static background 
		- Outputs of restoration methods (3)DL (5)LWB (5)SBR-RPCA.   
		- Outputs of the methods we propose (6)CS (7)PEOF (8)CS+PEOF
		- We also tried supplementing our "CS+PEOF" methods with an RPCA stage. The restoration result is shown in (9)CS+PEOF+RPCA.
		  As mentioned in the paper, we could remove the spatio-temporal noisy artifacts from the video but the visual and numerical quality of the mean image improved only marginally.

Set2 - Naming format : VideoName_SSIM_Dissimilarity
		-Intention of this set is to highlight the geometrical distortions introduced by each method.
		- Each individual image in the collage, except the ground truth is created in the following manner
			- 0.7*RestoredImage + 0.3*(1-SSIM_Map).*Red_Color. Hence, wherever the ssim values are lower, you will those regions getting highlighted with brighter red color.
			- You can observe that the current state of the art methods do not reconstruct the background correctly. Particularly, SBR-RPCA gives a very stable video, but is significantly distorted wrt the 	ground truth.



*Please note: If the files are sorted alphabetically or chronologically, VideoName_SSIM_Dissimilarity and  VideoName_Mean_Images will get arranged back to back for each video. It will be easy to toggle between the restoration result and corresponding SSIM dissimilarity map in the image viwer.