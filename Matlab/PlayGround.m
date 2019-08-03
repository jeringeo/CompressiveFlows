clc;
clear all;
addpath('YALL1_v1.4');
addpath('utils')
tic;
file = '/home/jerin/Cloud/Archives/CVPR/EvaluationSet/FullSet/Elephant.avi';
frames = readFrames(file);
reconFrames = frames;



reconFlowsFB = 0;
flows = load('/home/jerin/WorkingDir/TempOut/ElephantCSFlows.mat'); reconFlowsCS = flows.reconFlowsCS;
flows = load('/home/jerin/WorkingDir/TempOut/ElephantFBFlows.mat'); reconFlowsFB = flows.reconFlowsFB;
reconFlows = reconFlowsCS + reconFlowsFB;
reconFlows0 = 0;
% 
 origShape = size(reconFlows);
% 
% 
% 
% %flows = csflows;
% 
% 


% 
% [reconFrames, reconFlows0] = CSStabilizer(frames, reconFlows, 512, [8,8,4]);
% 
% outFile = strcat('/home/jerin/WorkingDir/TempOut/reconVideoCS0','.avi');
% outFrames = cat(2,frames, reconFrames);
% WriteVideo(outFile, outFrames, 50);
% imwrite(squeeze(mean(outFrames,3)),strcat('/home/jerin/WorkingDir/TempOut/','ReconCS0.png'));


[reconFrames, reconFlows] = CSStabilizer(reconFrames, reconFlows-reconFlows0, 1024, [8,8,1]);

outFile = strcat('/home/jerin/WorkingDir/TempOut/reconVideoCS1','.avi');
outFrames = cat(2,frames, reconFrames);
WriteVideo(outFile, outFrames, 50);
imwrite(squeeze(mean(outFrames,3)),strcat('/home/jerin/WorkingDir/TempOut/','ReconCS1.png'));


% reconFlowsS = resampleFlows(reconFlows,ceil(origShape./[4,4,4]));
% %reconFlowS = keepTopN(reconFlowsS,2241); 
% reconFlows = resampleFlows(reconFlowsS,origShape);

% reconFrames =  WarpVideo(frames, reconFlows, false);
 [reconFrames, reconFlows] = NormalOFCorrection(reconFrames);

 reconFlows = filterFlows(reconFlows,[32,32,32]);
 toc;

outFile = strcat('/home/jerin/WorkingDir/TempOut/reconVideo','.avi');
outFrames = cat(2,frames, reconFrames);


WriteVideo(outFile, outFrames, 50);
imwrite(squeeze(mean(outFrames,3)),strcat('/home/jerin/WorkingDir/TempOut/','Recon.png'));

function plotHighest(flows, n)
ftFlows = abs(fftshift(fftn(flows)));
[vals,idxs] = sort(-ftFlows(:));
vals = vals(1:n); idxs = idxs(1:n);
[r,c,t] = ind2sub(size(ftFlows,idxs));
scatter3(r,c,t);

end



function [cots, tracks] = getTracks(flows,nrPts)

dim = size(flows);

idxs = randsample(dim(1)*dim(2),nrPts);
[trackPtsR,trackPtsC] = ind2sub(dim(1:2),idxs);

tracks = zeros(nrPts,dim(3));
cots = zeros(nrPts,2);

for i =1:nrPts
    tracks(i,:) = flows(trackPtsR(i),trackPtsC(i),:);
    cots(i,:) = [trackPtsR(i),trackPtsC(i)];
end

end

function tracks = smoothTracks(tracks, cf)
len = size(tracks,2);
t = linspace(-1,1,len)*len;
kernal = exp(-((t/(len/cf)).^2)); ftkernal = ifftshift(kernal);

ftTracksS = fft(tracks,len,2).*ftkernal;


tracksS = ifft(ftTracksS,len,2);

tracks = tracksS;
end

function reconFlows = keepTopN(flows,n)

if isinf(n)
    reconFlows = flows;
    return;
end

ft = fftn(flows);
ftFil = zeros(size(ft));
[~,idxs] = sort(-abs(ft(:)));
[r,c,t] = ind2sub(size(flows),idxs(1:n));
for i=1:n
    ftFil(r(i), c(i), t(i)) = ft(r(i), c(i), t(i)) ;
end

reconFlows = ifftn(ftFil);
    

end


function [reconFrames, reconFlows] = CSStabilizer(frames, flows, nrPts, scale)

origShape = size(frames);
[origCots, origTracks] = getTracks(flows, nrPts);
origTracks = smoothTracks(origTracks,scale(3));
    
%downShape = [128, 128, 51];
downShape = ceil(origShape./scale);
[cots, tracks] = subsampleTracks(origCots, origTracks, origShape, downShape);

global Amat nrIters;
%Amat = PhiPsiBandLimited(cots,tracks/scale,downShape,bl);
nrIters = 0;
Amat = PhiPsi(cots,tracks,downShape);

A.times = @ATimes;
A.trans = @ATransTimes;

opts.tol = 1e-6;
lambda = 2; opts.rho = 2/lambda;
opts.maxit = 100000;
opts.print = 2;
[x, Out] = yall1(A, Amat.tracks, opts);

x = Amat.completeFT(x);

reconFlowFT = reshape(x,downShape);
reconDownFlows = ifftn(reconFlowFT);
reconDownFlows = gather(reconDownFlows);
reconFlows = resampleFlows(reconDownFlows,origShape);
reconFlows = filterFlows(reconFlows, [32, 32, 32]); % else small high freq dists are there

reconFrames = WarpVideo(frames, reconFlows, false);


end


function out = ATimes(x)
global Amat;
out = Amat.ATimes(x);
end


function out = ATransTimes(x)
global Amat ;
out = Amat.ATransTimes(x);

end