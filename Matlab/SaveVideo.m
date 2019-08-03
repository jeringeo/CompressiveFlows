clc;
clear all;
v = VideoReader('/home/jerin/Cloud/Archives/CVPR/EvaluationSet/FullSet/Dices.avi');

frames = read(v);
frames = squeeze(mean(frames,3))/255;

save('/home/jerin/WorkingDir/TempOut/Dices/Dices.mat', 'frames');