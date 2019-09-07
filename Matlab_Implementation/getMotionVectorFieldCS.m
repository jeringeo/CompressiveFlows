function mvfCS = getMotionVectorFieldCS(frames, nrPts, subsampling, clr, USE_GPU)

PointTrackingUtil = PointTrackingUtility();
origShape = size(frames);
[origCots, origTracks] = PointTrackingUtil.getPointTracks(frames, nrPts);
 
if size(origCots,1)<5
    disp('too less points');
    mvfCS = zeros(size(frames));
    return;

end

cots = origCots + clr(1:2);
shape = origShape + 2*clr;
downShape = ceil(shape./subsampling);
[cots, tracks] = PointTrackingUtil.subsampleTracks(cots, origTracks, shape, downShape);
disp(strcat('Number of tracks ', num2str(size(cots,1))));

global Amat nrIters;
nrIters = 0;
Amat = PhiPsi(cots,tracks,downShape, USE_GPU);

A.times = @ATimes;
A.trans = @ATransTimes;

opts.tol = 1e-8;
lambda = 2; opts.rho = 2/lambda;
opts.maxit = 100000;
opts.print = 0;


[x, ~] = yall1(A, Amat.tracks, opts);

x = Amat.completeFT(x);

reconFlowFT = reshape(x,downShape);
reconDownFlows = ifftn(reconFlowFT);
reconDownFlows = gather(reconDownFlows);
reconFlowsOrig = resampleFlows(reconDownFlows,shape);
reconFlowsOrig = reconFlowsOrig(1+clr(1):end-clr(1),1+clr(2):end-clr(2),:);
mvfCS = filterFlows(reconFlowsOrig,[12,12,64]); %Flows are further filtered, to remove some residual high frequency components introduced by upsampling
end


function out = ATimes(x)
global Amat;
out = Amat.ATimes(x);
end


function out = ATransTimes(x)
global Amat ;
out = Amat.ATransTimes(x);

end

function outFlows = resampleFlows(flows,outSize)

inSize = size(flows);
[Xin,Yin,Zin] = meshgrid(linspace(1,outSize(2),inSize(2)), linspace(1,outSize(1),inSize(1)), linspace(1,outSize(3),inSize(3)));
[X,Y,Z] = meshgrid(1:outSize(2), 1:outSize(1), 1: outSize(3));

outFlows = interp3(Xin,Yin,Zin,flows,X,Y,Z,'spline');

end
