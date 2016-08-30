function result_mask(result)

prob_prev = zeros(272, 640);
palette = imread(fullfile('..', 'car', sprintf('%08d.jpg',result.frames(1,1)))); 

for i=1:size(result.frames,1)
    
    f = result.frames(i,1); % frame number
    vis = palette;
    vis = vis(120:240, :,:);
    vis = insertText(vis, [size(vis,2)-80 size(vis,1)-30], sprintf('frame %03d',f),'BoxColor','black','BoxOpacity',0.6,'TextColor','yellow');
    if i==1
        [M, c_map]= rgb2ind(vis, 256);
        imwrite(M, c_map, 'object.gif','gif','LoopCount',inf,'DelayTime',0)
    else
        [M, c_map]= rgb2ind(vis, c_map);
        imwrite(M, c_map, 'object.gif','gif','WriteMode','append','DelayTime',0)
    end
    
    % update
    im = imread(fullfile('..', 'car', sprintf('%08d.jpg',f))); 
    prob = result.prob(:,:,f);    % probability of frame i
    prob = prob/max(prob(:));
    T = result.T(:,:,f);    % transformation to next frame 
    try
        tform = affine2d(T');
        [palette, prob_prev] = update_palette(palette, T, im, prob, prob_prev);
        
    catch
        break;
    end
end
% imwrite(F, 'probs.gif', 'DelayTime', 0, 'LoopCount',inf);
