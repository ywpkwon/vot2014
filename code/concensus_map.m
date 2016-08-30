function map = concensus_map(x, y)

p = [x(:), y(:)];
d = sqrt(dist2(p,p));
mu = mean(d(:));
fsize = round(1.5*mu);
sigma = mu/6;
        
map = zeros(272, 640);
map(sub2ind(size(map), y, x)) = 1;
h = fspecial('gaussian',[fsize, fsize], sigma);
map = imfilter(map, h, 'same');
map = map/max(map(:));