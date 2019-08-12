function mvfPEOF = getMotionVectorFeildPEOF(frames)

shape = size(frames);
refFrame = squeeze(mean(frames,3));

flows = zeros(shape(1), shape(2), shape(3));

opticFlow = opticalFlowFarneback;
for f = 1:size(frames,3)
    
    flow = estimateFlow(opticFlow,refFrame); 
    flow = estimateFlow(opticFlow,squeeze(frames(:,:,f)));
    flows(:,:,f) = flow.Vy + 1j*flow.Vx;
    
end
flowsOrig = flows - mean(flows,3);
mvfPEOF = filterFlows(flowsOrig, [32,32, 64]);%Flows are further filtered, consistent with the assumption of smooth flows
end