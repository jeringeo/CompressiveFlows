function [cots, tracks] = subsampleTracks(cots, tracks, inShape, downShape)

len = size(tracks,2);
t = 1:len;
downT = linspace(t(1),t(end),downShape(3));

downTracks = NaN;

for i = 1:size(tracks,1)
    downTrack = interp1(t,tracks(i,:),downT);
    if isnan(downTracks)
        downTracks = zeros(size(tracks,1),length(downTrack));
    end
    downTracks(i,:) = downTrack;
end

tracks = downTracks;

cots = (cots-1).*((downShape(1:2)-1)./(inShape(1:2)-1)) + 1;

shapeX = downShape(1:2);
cots = round(squeeze(cots));


idxs = sub2ind(shapeX,cots(:,1), cots(:,2));
[~, uniqueIdxs] = unique(idxs);
cots = cots(uniqueIdxs,:);
tracks = tracks(uniqueIdxs,:);



end