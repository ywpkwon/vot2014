% x = 4xn data. [x1 y1 x1 y2]' * n columns
% M = homography or affine
function [inliers, M] = ransac_homo_distfn(M, x, t)

if isempty(M), 
    M=[]; inliers=[]; return
end

p1 = x(1:2,:);
p2 = x(3:4,:);
n = size(x,2);

p1h = [p1; ones(1,n)]; % homogeneous
p2h = [p2; ones(1,n)]; 

p1ht = M*p1h;
p1ht = p1ht./repmat( p1ht(end,:),3,1);
% dist_for = sqrt(sum((p1ht-p2h).^2));
dist = sqrt(sum((p1ht-p2h).^2));

% p2ht = M\p2h;
% p2ht = p2ht./repmat( p2ht(end,:),3,1);
% dist_rev = sqrt(sum((p2ht-p1h).^2));
% dist = (dist_for+dist_rev)/2;
inliers = find(dist<t);

% INLIERS.inliers = inliers;
% INLIERS.tiebreaker = numel(find(dist<t*1000));