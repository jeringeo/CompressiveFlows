function [reconFrames, reconFlowsOrig, reconFlowsFil] = CSStabilize(frames, nrPts, subsampling, clr)

origShape = size(frames);
[origCots, origTracks] = getPointTracks(frames, nrPts);
 
if size(origCots,1)<5
    disp('too less points');
    reconFrames = frames;
    reconFlowsOrig = zeros(size(reconFrames));
    reconFlowsFil = zeros(size(reconFrames));
    return;

end

cots = origCots + clr(1:2);
shape = origShape + 2*clr;
%downShape = [128, 128, 51];
downShape = ceil(shape./subsampling);
[cots, tracks] = subsampleTracks(cots, origTracks, shape, downShape);
disp(strcat('Number of tracks ', num2str(size(cots,1))));

global Amat nrIters;
%Amat = PhiPsiBandLimited(cots,tracks/scale,downShape,bl);
nrIters = 0;
Amat = PhiPsi(cots,tracks,downShape);

A.times = @ATimes;
A.trans = @ATransTimes;

opts.tol = 1e-8;
lambda = 2; opts.rho = 2/lambda;
opts.maxit = 100000;
opts.print = 0;


[x, Out] = yall1(A, Amat.tracks, opts);

x = Amat.completeFT(x);

reconFlowFT = reshape(x,downShape);
reconDownFlows = ifftn(reconFlowFT);
reconDownFlows = gather(reconDownFlows);
reconFlowsOrig = resampleFlows(reconDownFlows,shape);
reconFlowsOrig = reconFlowsOrig(1+clr(1):end-clr(1),1+clr(2):end-clr(2),:);
reconFlowsFil = filterFlows(reconFlowsOrig,[12,12,64]); % else small high freq dists are there
%reconFlowsFil = reconFlowsOrig;
reconFrames = WarpVideo(frames, reconFlowsFil, false);


end

function wts = getWeights(shape)
cf = [1,1,1];
[Wc, Wr, Wt] = meshgrid(1:shape(2), 1:shape(1), 1:shape(3));

dists = ((Wr -shape(1)/2)/cf(1)).^2 + ((Wc -shape(2)/2)/cf(2)).^2 + ((Wt -shape(3)/2)/cf(3)).^2;
mask = sqrt(dists);
wts = ifftshift(mask);
wts = wts(:);
end



function out = ATimes(x)
global Amat;
out = Amat.ATimes(x);
end


function out = ATransTimes(x)
global Amat ;
out = Amat.ATransTimes(x);

end