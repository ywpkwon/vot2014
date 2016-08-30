function [x1,x2,y1,y2] = concensus_bbox(map, thr)

[r,c] = ind2sub(size(map),find(map>=thr));
x1=min(c(:));x2=max(c(:));y1=min(r(:));y2=max(r(:));