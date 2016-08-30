function [palette_new, prob_new] = update_palette(palette, T, im, prob, prob_prev)

prob = prob/max(prob(:));
prob_prev = prob_prev * 0.9;   % decay
total_prob = max(prob_prev,prob);

palette = 0.9*palette + 0.1*im;

% thr = 0.1;
% palette(repmat(total_prob>thr & prob>=prob_prev,1,1,3)) = im(repmat(total_prob>thr & prob>=prob_prev,1,1,3));
% palette(repmat(total_prob>thr & prob<prob_prev,1,1,3)) = palette(repmat(total_prob>thr & prob<prob_prev,1,1,3));
% palette(repmat(prob>=prob_prev,1,1,3)) = im(repmat(prob>=prob_prev,1,1,3));
% palette(repmat(total_prob<thr, 1, 1, 3)) = 0;

% apply T for next frame
fixed = imref2d([272, 640]);
tform = affine2d(T');
prob_new = imwarp(total_prob, tform, 'Outputview', fixed);   % decay
palette_new = imwarp(palette, tform, 'Outputview', fixed);
