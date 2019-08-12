classdef PhiPsi
    
    
    properties
        tracks = 0;
        
        shape = 0;
        selIdxs=0;
        
        transOut0 =0 ;
        USE_GPU = gpuDeviceCount>0;
    end
    
    methods
        function obj = PhiPsi(cots, tracks,shape, USE_GPU)
            obj.shape = shape;
            obj = obj.createCoordinates(shape, cots, tracks);
            obj.tracks = tracks;
            obj.tracks = obj.tracks(:);
            obj.USE_GPU = USE_GPU;
            if obj.USE_GPU,  obj.tracks = gpuArray(obj.tracks); end
            
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
            
            if obj.USE_GPU
                obj.transOut0 = gpuArray(obj.transOut0);
                obj.selIdxs = gpuArray(obj.selIdxs);
            end
            
        end
        
        function out = ATimes(obj,x)
            
            ftVol = reshape(x, obj.shape);
            out = ifftn(ftVol);
            out = out(obj.selIdxs);
        end
        
        function out = ATransTimes(obj,x)
            
            obj.transOut0(obj.selIdxs) = x;
            out = fftn(obj.transOut0);
            out = out(:);
        end
        
        function out = completeFT(~, ft)
            out = ft;
            
        end
    end
end




