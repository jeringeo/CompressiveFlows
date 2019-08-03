function frames = correctFlowsOF(frames)

flows = obtainFlows(frames);



end



function flows = obtainFlows(frames)

opticalFlow = vision.OpticalFlow('ReferenceFrameSource', 'Input port');                                                          

flows = zeros(size(frames,1),size(frames,2),2, size(frames,3));

refFrame = squeeze(mean(frames,3));
for f=1:size(frames,3)
    flow = step(opticalFlow, refFrame, squeeze(frames(:,:,f)));
    
end

end