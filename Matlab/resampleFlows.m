function outFlows = resampleFlows(flows,outSize)

inSize = size(flows);
[Xin,Yin,Zin] = meshgrid(linspace(1,outSize(2),inSize(2)), linspace(1,outSize(1),inSize(1)), linspace(1,outSize(3),inSize(3)));
[X,Y,Z] = meshgrid(1:outSize(2), 1:outSize(1), 1: outSize(3));

outFlows = interp3(Xin,Yin,Zin,flows,X,Y,Z,'spline');

end



% function outFlows = resampleFlows(flows,outSize)
% 
% s = size(flows);
% sh = ceil(s/2);
% oh = ceil(outSize/2);
% ftFlows = fftshift(fftn(flows));
% ftReFlows = zeros(outSize);
% 
% ftReFlows(oh(1)-sh(1):oh(1)-sh(1)+s(1)-1,oh(2)-sh(2):oh(2)-sh(2)+s(2)-1,oh(3)-sh(3):oh(3)-sh(3)+s(3)-1) = ftFlows;
% outFlows = ifftn(ifftshift(ftReFlows));
% 
% end

