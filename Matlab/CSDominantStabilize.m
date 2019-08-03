function [reconFrames, reconFlows] = CSDominantStabilize(frames)

origShape = size(frames);
[origCots, origTracks] = getPointTracks(frames, 1024);


    
%downShape = [128, 128, 51];
downShape = ceil(origShape./[4,4,4]);
[cots, tracks] = subsampleTracks(origCots, origTracks, origShape, downShape);
domSupports = getDominantTimeSupports(origTracks);

global Amat nrIters;
bl = [16, 16, 64];
Amat = PhiPsiBandLimited(cots,tracks,downShape,bl,domSupports);
nrIters = 0;
%Amat = PhiPsi(cots,tracks,downShape);

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
reconFlows = filterFlows(reconFlows,[32,32,50]); % else small high freq dists are there

reconFrames = WarpVideo(frames, reconFlows, false);


end


function domSupports = getDominantTimeSupports(tracks)
amps = abs(fft(real(tracks),size(tracks,2),2));
medAmps = median(amps,1);
sortAmps = abs(sort(-medAmps));
energy = cumsum(sortAmps.^2); energy = energy/(energy(end));
cof = find(energy>.9,1);

domSupports = medAmps>sortAmps(cof);

end


function out = ATimes(x)
global Amat;
out = Amat.ATimes(x);
end


function out = ATransTimes(x)
global Amat ;
out = Amat.ATransTimes(x);

end