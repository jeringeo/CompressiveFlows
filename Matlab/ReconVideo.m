clc;
clear all;
%[origCots, origTracks, flows, frames] = loadVideoData('/home/jerin/WorkingDir/TempOut/HandWritten/Data.mat', 256);
frames = load('Data/handWritten.mat'); frames = frames.frames;

outFile = '/home/jerin/WorkingDir/TempOut/reconVideo.avi';
reconFlows = load('/home/jerin/WorkingDir/TempOut/reconFlows.mat');
reconFlows = gather(reconFlows.reconFlows);


outFrames = WarpVideo(frames, reconFlows, false);
outFrames = cat(2,frames, outFrames);
WriteVideo(outFile, outFrames, 50);

