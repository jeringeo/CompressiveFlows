function WriteVideo(filePath, frames, fps)

nrFrames = size(frames,3);
v = VideoWriter(filePath,'Motion JPEG AVI');
v.Quality = 100;
v.FrameRate = fps;
open(v);

for i = 1:nrFrames
   outFrame = squeeze(frames(:,:,i));
   writeVideo(v,outFrame);
end

close(v);


end