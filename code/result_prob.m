function result_prob()

result = load('result');
result = result.result;
cm = colormap(hot(255));
prob_prev = zeros(272, 640);
iptsetpref('ImshowBorder','tight')
figure;
for i=1:size(result.frames,1)
    f = result.frames(i,1); % frame number
    T = result.T(:,:,f);    % transformation to next frame    
    
    prob_i = result.prob(:,:,f);    % probability of frame i
    prob = prob_prev+prob_i;        % probability from prev frame
    prob = prob/sum(prob(:));       % accumulated probability
    
    % for gif save
    im_prob = prob_i(90:240,:,:);
    im_prob = uint8(im_prob*(size(cm,1)-1)/max(im_prob(:)));
    im_prob = ind2rgb(im_prob, cm);
    im_prob = insertText(im_prob, [size(im_prob,2)-80 size(im_prob,1)-30], sprintf('frame %03d',f),'BoxColor','black','BoxOpacity',0.6,'TextColor','yellow');
    
    im = imread(fullfile('..', 'car',sprintf('%08d.jpg',f)));
    im = im(90:240,:,:);
    
    h1=imshow(im); hold on; h2=imshow(im_prob);
    set( h1, 'AlphaData', .9 );
    set( h2, 'AlphaData', .5 );
    
    drawnow
    frame = getframe(gcf);
    plotim = frame2im(frame);    
    
    fname_prob = fullfile('..','output','prob', sprintf('%03d.jpg', i));
    fname_prob_embed = fullfile('..','output','prob_embed', sprintf('%03d.jpg', i));
    imwrite(im_prob, fname_prob);
    imwrite(plotim, fname_prob_embed);
    
    if i==1
        [M1, c_map1]= rgb2ind(im_prob,256);
        [M2, c_map2] = rgb2ind(plotim, 256, 'nodither');
        imwrite(M1, c_map1, 'prob.gif','gif','LoopCount',inf,'DelayTime',0)
        imwrite(M1, c_map2, 'prob_embed.gif','gif','LoopCount',inf,'DelayTime',0)
        
    else
        [M1, c_map1]= rgb2ind(im_prob, c_map1);
        [M2, c_map2] = rgb2ind(plotim, c_map2, 'nodither');
        imwrite(M1, c_map1, 'prob.gif','gif','WriteMode','append','DelayTime',0)
        imwrite(M2, c_map2, 'prob_embed.gif','gif','WriteMode','append','DelayTime',0)
        
    end
    
    % update
    fixed = imref2d([272, 640]);
    try
        prob_prev = imwarp(prob, affine2d(T'), 'Outputview', fixed);
    catch
        break;
    end
end
% imwrite(F, 'probs.gif', 'DelayTime', 0, 'LoopCount',inf);
