clc;
clear all;
addpath('utils')
rng(27);
tic;
file = '/home/jerin/Cloud/Archives/CVPR/EvaluationSet/FullSet/Elephant.avi';
frames = readFrames(file);

flows = load('/home/jerin/WorkingDir/TempOut/ElephantCSFlows.mat'); reconFlowsCS = flows.reconFlowsCS;
flows = load('/home/jerin/WorkingDir/TempOut/ElephantFBFlows.mat'); reconFlowsFB = flows.reconFlowsFB;
reconFlows = reconFlowsCS + reconFlowsFB;


[cots, tracks] = getPointTracks(frames, inf);
gtTracks = getGTTracks(reconFlows, cots);
tracks = smoothTracks(tracks, 32);

ptTracks = zeros(size(cots,1), 2, size(tracks,2));
ptTracks(:,1,:) = cots(:,2) + imag(tracks);
ptTracks(:,2,:) = cots(:,1) + real(tracks);

markedFrames = zeros(size(frames,1),size(frames,2),3, size(frames,3));

for f = 1: size(frames,3)
    markedFrames(:,:,:,f) = insertMarker(squeeze(frames(:,:,f)),squeeze(ptTracks(5,:,f)),'size',10);
    
end


outFile = strcat('/home/jerin/WorkingDir/TempOut/tracking','.avi');



nrFrames = size(markedFrames,4);
v = VideoWriter(outFile,'Motion JPEG AVI');
v.FrameRate = 50;
open(v);

for i = 1:nrFrames
   outFrame = squeeze(markedFrames(:,:,:,i));
   writeVideo(v,outFrame);
end

close(v);


function tracks = getGTTracks(flows,cots)

dim = size(flows);


tracks = zeros(size(cots,1),dim(3));
cots = round(cots);

for i =1:size(cots,1)
    tracks(i,:) = flows(cots(i,1),cots(i,2),:);
end

end


function tracks = smoothTracks(tracks, cf)
len = size(tracks,2);
t = linspace(-1,1,len)*len/2;
kernal = exp(-((t/(cf)).^4)); ftkernal = ifftshift(kernal);

ftTracksS = fft(tracks,len,2).*ftkernal;


tracksS = ifft(ftTracksS,len,2);

tracks = tracksS;
end