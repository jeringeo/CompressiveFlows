clc;
clear all;
close all;
rng(27);

addpath('YALL1_v1.4');


files = getAllVideoFiles('/home/jerin/Cloud/ICCV/EvaluationSet/FullSet/');
files = {'/home/jerin/Cloud/ICCV/EvaluationSet/FullSet/Elephant.avi'};
%files = {'/home/jerin/WorkingDir/Videos/Chosen/CV.avi'};
global outFol;
outFol = '/home/jerin/WorkingDir/TempOut/Qualcomm/';
%outFol = '/home/jerin/WorkingDir/TempOut/61/';
times = zeros(length(files),1);
for i = 1:length(files)
    file = files{i};
   
    fileTag = getFileTag(file);
    frames = readFrames(file);
   
    fileStart = tic;
    reconFrames = reconVideo(frames);
    times(i) = toc(fileStart);
    writeOutput(reconFrames, getFileTag(files{i}));
end

for i=1:length(files)
   disp(strcat(getFileTag(files{i}),',',num2str(times(i)))); 
end


function reconFrames = reconVideo(frames)






[reconFrames, csFlowsOrig, csFlowsFil] = CSStabilize(frames, inf, [8,8,1], [0,0,0]);
[reconFrames, resFlowsOrig, resFlowsFil] = NormalOFCorrection(frames);
%toc;




%writeVideoAndMean(frames, reconFrames, strcat(fileTag,'CS1'));


%[reconFrames, resFlowsOrig, resFlowsFil] = NormalOFCorrection(frames);
%writeVideoAndMean(frames, reconFrames, strcat(fileTag,'Final'));




%save(strcat(outFol,fileTag,'.mat'),'csFlowsOrig','csFlowsFil');


end

function writeVideoAndMean(orig, reconFrames, tag)

file = strcat(outFol,tag);

outFrames = cat(2,orig, reconFrames);
WriteVideo(strcat(file,'.avi'), outFrames, 50);
imwrite(squeeze(mean(outFrames,3)),strcat(file,'.png'));
end

function writeOutput(reconFrames, tag)
global outFol;
file = strcat(outFol,tag);


WriteVideo(strcat(file,'.avi'), reconFrames, 50);
%imwrite(squeeze(mean(reconFrames,3)),strcat(file,'.png'));
end

function tag =  getFileTag(file)
a = strsplit(file,'.');
a  = strsplit(a{1},'/');
tag = convertCharsToStrings(a{end});

end

function vidFiles = getAllVideoFiles(folder)
files = dir(strcat(folder,'*.avi'));
vidFiles = {};

for i=1:length(files)
    vidFiles{i} = strcat(folder,files(i).name);
    
end

end


function plotHighestCoeffs(cf)


subplot(1,3,1);
[r, c, t] = getTopCoeffs(reconFlows0, cf);
scatter3(r,c,t);

subplot(1,3,2);
[r, c, t] = getTopCoeffs(reconFlows, cf);
scatter3(r,c,t);

subplot(1,3,3);
[r, c, t] = getTopCoeffs(reconFlows0+reconFlows, cf);
scatter3(r,c,t);

end