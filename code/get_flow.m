function [p1, p2, nndr] = get_flow(im1, im2, xs, ys)
    
    [im_height, im_width, ~] = size(im1);
    p1 = [];
    p2 = []; 
    nndr = [];
    patch_size = 7;
    
    for xi=1:numel(xs)
        for yi=1:numel(ys)
            x = xs(xi);
            y = ys(yi);

            % limit check
            if y-patch_size<1, continue; end
            if x-patch_size<1, continue; end
            if y+patch_size>im_height, continue; end
            if x+patch_size>im_width, continue; end
            
            % source : image patch centered at (x,y)
            source = im1(y-patch_size:y+patch_size, x-patch_size:x+patch_size,:);
            
            % 2-level search
            range = -30:3:30;
            [t_patches, t_pos] = im2patches2(im2, x+range, y+range, [patch_size, patch_size]);
            nnd = dist2(single(source(:)'), single(t_patches));
            [~, nn] = sort(nnd);
            found_pos = t_pos(nn(1),:);
            
            range = -5:5;
            [t_patches, t_pos] = im2patches2(im2, found_pos(1)+range, found_pos(2)+range, [patch_size, patch_size]);
            nnd = dist2(single(source(:)'), single(t_patches));
            [d, nn] = sort(nnd);
            found_pos = t_pos(nn(1),:);

            p1 = [p1; x, y];
            p2 = [p2; found_pos];
            nndr = [nndr; d(1)/d(2)];
        end
    end
end


function [patches, pos] = im2patches2(im, xsample, ysample, patch_size)
    m = patch_size(1); 
    n = patch_size(2);
    patches = [];
    pos = [];
    for xi=1:numel(xsample)
        for yi=1:numel(ysample)
            x = xsample(xi);
            y = ysample(yi);
            
            if any([y-m x-m] < 1) || any([y+m x+n] > [size(im,1) size(im,2)])
                continue
            end
            patch = im(y-m:y+m,x-n:x+n,:);
            patches = [patches patch(:)];
            pos = [pos; x, y];
        end
    end
    patches = patches';
end
