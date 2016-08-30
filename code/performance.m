function errors = performance(frames)

truth = load(fullfile('..', 'car','groundtruth.txt'))+1; % maybe zero based?
overlaps = zeros(size(frames,1), 1);
mask1 = uint8(zeros(272, 640));
mask2 = uint8(zeros(272, 640));

for i=1:size(frames,1)
    frame = frames(i,2:end);
    framei = round(frame);
    framet = truth(frames(i,1),:);
    
    mask1(:) = 0; mask1(framei(4):framei(2), framei(1):framei(5))=1;
    mask2(:) = 0; mask2(framet(4):framet(2), framet(1):framet(5))=1;
    union = mask1|mask2;
    inters = mask1&mask2;
    overlaps(i) = sum(inters(:))/sum(union(:));
end

errors = 1-overlaps;
% fprintf('error: %.3f\n', mean(errors));
% f_idx = frame(:,1);
% figure; plot(f_idx, errors); axis([f_idx(1) f_idx(end) 0 1]);
% xlabel('frame number');
% ylabel('overlap');




