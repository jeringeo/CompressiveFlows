clc; clear all; close all;


addpath('YALL1_v1.4');


%%---------------------Defining Folders---------------------%
inputFolder = '../Dataset/DistortedVideos/';
outputFolder = '/home/jerin/WorkingDir/TempOut/Repo/';



%-------------------------Settings-------------------------%
USE_GPU = gpuDeviceCount>0; %Set to False if you don't waant to use gpu


VideoUtil = VideoUtility();
files = VideoUtil.getAllVideoFiles('../Dataset/DistortedVideos/');


for i = 1:length(files)
    file = files{i};
    
    fileTag = VideoUtil.getFileTag(file);
    frames = VideoUtil.readFrames(file);
    
    reconFrames = reconVideo(frames, VideoUtil, USE_GPU);
    
    VideoUtil.writeOutput(outputFolder, reconFrames, fileTag);
end


function reconFrames = reconVideo(frames, VideoUtil, USE_GPU)
    mvfCS = getMotionVectorFieldCS(frames, inf, [8,8,1], [0,0,0], USE_GPU);
    reconFramesCS = VideoUtil.WarpVideo(frames, mvfCS, false);
    mvfPEOF = getMotionVectorFeildPEOF(reconFramesCS);
    reconFrames = VideoUtil.WarpVideo(reconFramesCS, mvfPEOF, false);
end



