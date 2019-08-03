function frames = readFrames(filePath)
v = VideoReader(filePath);

frames = read(v);
frames = squeeze(mean(frames,3))/255;

end