
function wrappedFrames = WarpVideo(frames, flows , fwdWarp)

[rows, cols, nrFrames, ~] = size(frames);

[c,r] = meshgrid(1:cols,1:rows);
vol = flows + r + 1j*c;

mapR = real(vol); mapC  = imag(vol);

mapR(mapR<1) = 1; mapR(mapR>rows) = rows;
mapC(mapC<1) = 1; mapC(mapC>cols) = cols;


wrappedFrames = zeros(size(frames));
wrappedFrame = zeros(rows, cols);



for i = 1:nrFrames
    frameMapR = mapR(:,:,i);
    frameMapC = mapC(:,:,i);
    
    
    frame = squeeze(frames(:,:,i));
    
    
    
    if fwdWarp
        
        wrappedIdxs = sub2ind([rows, cols] , round(frameMapR(:)), round(frameMapC(:)));
        wrappedFrame(wrappedIdxs) = frame;
    else
        wrappedFrame = interp2(frame,frameMapC, frameMapR);
    end
    
    wrappedFrames(:,:,i) = wrappedFrame;
    
    
end

end