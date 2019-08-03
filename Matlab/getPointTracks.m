function [cots, tracks] = getPointTracks(frames, nrPts)


nrFrames = size(frames,3);
pointTracker = vision.PointTracker('BlockSize',[21,21]);
firstFrame = squeeze(frames(:,:,1));


%setPoints(pointTracker,points);
points = detectInterestPoints(firstFrame);
points = removeBorderPts(points, [size(frames,1), size(frames,2)], 24);
nrPts = min(nrPts, size(points,1));
points = points(1:nrPts,:);
initialize(pointTracker,points,firstFrame);
%[points,point_validity,scores] = pointTracker(firstFrame);

tracks = zeros(nrPts,nrFrames,2);
scores = zeros(nrPts,nrFrames);
validity = true;
for i = 1:nrFrames
    frame = squeeze(frames(:,:,i));
    [points,point_validity,scores(:,i)] = pointTracker(frame);
    tracks(:,i,:) = points(:,end:-1:1);
    validity = validity&point_validity;
end
tracks = tracks(validity,:,:);
tracks = filterCotShifts(tracks);


cots = mean(tracks,2);
tracks = tracks-cots;
tracks = tracks(:,:,1) + 1j*tracks(:,:,2);
cots = squeeze(cots);

%[cots, tracks] = filterBadTracks(cots, tracks);
tracks = smoothTracks(tracks,64);
disp(strcat('Nr points  ',num2str(size(cots,1))));
end


function tracks = filterCotShifts(tracks)
mid = floor(size(tracks,2)/2);
cotF = mean(tracks(:,1:mid,:),2);
cotS = mean(tracks(:,mid+1:2*mid,:),2);

dists = squeeze(sqrt(sum((cotF-cotS).^2,3)));

validTracks = dists<3;

tracks = tracks(validTracks,:,:);


end

function points = removeDuplicates(pts, shape)
pts = round(pts);
idxs = sub2ind(shape,pts(:,2), pts(:,1));
[~, idxs] = unique(idxs);
points = pts(idxs,:);


end

function points = joinPts(pts, shape)
points = [];

for i = 1:length(pts)
    sPts = pts{i};
    points = vertcat(points,sPts.Location);
end
points = removeDuplicates(points, shape);
end

function points = detectInterestPoints(frame)

surf = detectSURFFeatures(frame);
brisk = detectBRISKFeatures(frame);
fast = detectFASTFeatures(frame);
harris = detectHarrisFeatures(frame);
points = joinPts({surf, brisk, fast, harris}, size(frame));
end

function points =  removeBorderPts(pts, shape, clr)
validR = ((pts(:,2)>clr) & (pts(:,2)<(shape(1)-clr)));
validC = ((pts(:,1)>clr) & (pts(:,1)<(shape(2)-clr)));

validPts = validR & validC;
points = pts(validPts,:);
end


function [ft, ref] = reduce(tracks, n)
ft = fft(tracks, size(tracks,2), 2)/sqrt(size(tracks,2));
medFT = squeeze(median(abs(ft),1));
[~, idxs] = sort(-medFT);
ft = abs(ft(:,idxs(1:n)));
ref = squeeze(median(abs(ft),1));

end

function tracks = consistencyFilter(tracks, cf)
ft = fft(tracks, size(tracks,2), 2);
medFT = squeeze(median(abs(ft),1));

[vals,idxs] = sort(-medFT(:));
energy = cumsum(vals.^2); energy = energy/energy(end);

idxs = idxs(energy<cf);

ftRef = zeros(size(ft));
ftRef(:,idxs) = ft(:,idxs);
tracks = ifft(ftRef, size(tracks,2), 2);

end


%
% function [cots, tracks] = filterBadTracks(cots, tracks)
%
% [ft, ref] = reduce(tracks, 11);
%
% diff = sqrt(mean((abs(ft - ref)).^2,2));
%
% validPts = diff < 100*sqrt(mean(diff.^2));
%
% cots = cots(validPts,:); tracks = tracks(validPts, :);
%
% end


function [cots, tracks] = filterBadTracks(cots, tracks)
origTracks = tracks;

tracks = consistencyFilter(tracks,.9);
mid = floor(size(tracks,2)/2);
tracks = tracks(:,1:2*mid);
ft1 = abs(fft(tracks(:,1:mid), mid, 2)); ft1 = normr(ft1);
ft2 = abs(fft(tracks(:,mid:end), size(tracks,2)-mid, 2)); ft2 = normr(ft2);

strength = sum(ft1.*ft2,2);
std = sqrt(sum((abs(tracks)).^2,2));

validStrongPts = strength>median(strength);
validRMSPts = std > median(std);
validPts = validStrongPts & true;
disp(strcat('Nr Points ', num2str(sum(validPts))));
cots = cots(validPts,:); tracks = origTracks(validPts, :);

end


function tracks = smoothTracks(tracks, cf)
len = size(tracks,2);
t = linspace(-1,1,len);
kernal = exp(-((t/(cf)).^2)); ftkernal = ifftshift(kernal);

ftTracksS = fft(tracks,len,2).*ftkernal;


tracksS = ifft(ftTracksS,len,2);

tracks = tracksS;
end