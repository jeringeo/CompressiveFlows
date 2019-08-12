function flows = filterFlows(flows, cf)
flows = flows - mean(flows,3);
shape = size(flows);


FT = fftn(flows);

[Wc, Wr, Wt] = meshgrid(1:shape(2), 1:shape(1), 1:shape(3));

dists = ((Wr -shape(1)/2)/cf(1)).^2 + ((Wc -shape(2)/2)/cf(2)).^2 + ((Wt -shape(3)/2)/cf(3)).^2;
mask = exp(-dists.^2);
mask = ifftshift(mask);
FT = FT.*mask;
flows = ifftn(FT);

end
