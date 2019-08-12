classdef VideoUtility
    
    
    methods
        function vidFiles = getAllVideoFiles(~,folder)
            files = dir(strcat(folder,'*.avi'));
            vidFiles = {};
            
            for i=1:length(files)
                vidFiles{i} = strcat(folder,files(i).name);
                
            end
            
        end
        
        function tag =  getFileTag(~,file)
            a = strsplit(file,'.');
            a  = strsplit(a{end-1},'/');
            tag = convertCharsToStrings(a{end});
            
        end
        
        
        function frames = readFrames(~, filePath)
            v = VideoReader(filePath);
            
            frames = read(v);
            frames = squeeze(mean(frames,3))/255;
            
        end
        
        
        
        function wrappedFrames = WarpVideo(~,frames, flows , fwdWarp)
            
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
        
        function writeOutput(~,outFol, reconFrames, tag)
            
            file = strcat(outFol,tag);
            
            
            WriteVideo(strcat(file,'.avi'), reconFrames, 50);
            imwrite(squeeze(mean(reconFrames,3)),strcat(file,'.png'));
        end
        
        
        
    end
    
end


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