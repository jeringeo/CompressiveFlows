classdef PhiPsiBandLimited
    
    
    properties
        tracks = 0;
        
        shape = 0;
        selIdxs= 0;
        
        transOut0 = 0 ;
        validFreqs = 0 ;
        ftVol = 0;
    end
    
    methods
        function obj = PhiPsiBandLimited(cots, tracks,shape, freqCutoffs, domTime)
            obj.shape = shape;
            obj = obj.setValidFreqs(shape,freqCutoffs, domTime);
            obj = obj.createCoordinates(shape, cots, tracks);
            obj.tracks = tracks;
            obj.tracks = obj.tracks(:);
            obj.tracks = gpuArray(obj.tracks);            
        end
        
        function obj = setValidFreqs(obj, shape, cf, domTime)
            [Wc, Wr, Wt] = meshgrid(1:shape(2), 1:shape(1), 1:shape(3));
            
            dists = ((Wr -shape(1)/2)/cf(1)).^2 + ((Wc -shape(2)/2)/cf(2)).^2 + ((Wt -shape(3)/2)/cf(3)).^2;
            
            dists = ifftshift(dists);
            obj.validFreqs = dists<=1;
            obj.validFreqs(:,:,~domTime) = 0;
            obj.ftVol = gpuArray(zeros(shape));
            
        end
        
        
        function obj = createCoordinates(obj, shape, cots, tracks)
                    
            nrPts = size(tracks,1);
            pts = zeros(nrPts,shape(3));
            obj.selIdxs = zeros(prod(shape),1);
    

            for i=1:nrPts
                for j=1:shape(3)
                    
                    pts(i,j) = sub2ind(shape,cots(i,1), cots(i,2), j);
       
       
                end                
            end
            obj.selIdxs = pts(:);
            obj.transOut0 = zeros(shape);
            
            obj.transOut0 = gpuArray(obj.transOut0);
            obj.selIdxs = gpuArray(obj.selIdxs);
            
        end
        
        function out = ATimes(obj,x)
         obj.ftVol(obj.validFreqs) = x;
         out = ifftn(obj.ftVol);
         out = out(obj.selIdxs);
        end
        
        function out = ATransTimes(obj,x)           
            obj.transOut0(obj.selIdxs) = x;
            out = fftn(obj.transOut0);
            out = out(obj.validFreqs);
            %out = out(:);            
        end
        
        function out = completeFT(obj, ft)
            obj.ftVol(obj.validFreqs) = ft;
            out = obj.ftVol;
            
        end
        
    end
end




