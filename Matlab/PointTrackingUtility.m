classdef PointTrackingUtility
    methods
        function [cots, tracks] = getPointTracks(~,frames, nrPts)
            
            
            nrFrames = size(frames,3);
            pointTracker = vision.PointTracker('BlockSize',[21,21]);
            firstFrame = squeeze(frames(:,:,1));
            
            
            
            points = detectInterestPoints(firstFrame);
            points = removeBorderPts(points, [size(frames,1), size(frames,2)], 24);
            nrPts = min(nrPts, size(points,1));
            points = points(1:nrPts,:);
            initialize(pointTracker,points,firstFrame);
            
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
        
        function [cots, tracks] = subsampleTracks(~,cots, tracks, inShape, downShape)
            
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
        
    end
    
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



function tracks = smoothTracks(tracks, cf)
len = size(tracks,2);
t = linspace(-1,1,len);
kernal = exp(-((t/(cf)).^2)); ftkernal = ifftshift(kernal);

ftTracksS = fft(tracks,len,2).*ftkernal;


tracksS = ifft(ftTracksS,len,2);

tracks = tracksS;
end