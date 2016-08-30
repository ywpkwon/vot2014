function [x1,x2,y1,y2] = refine_frame(frame, probability, s, thr)

frame = round(frame);
x1=min(frame(1:2:end)); x2=max(frame(1:2:end));
y1=min(frame(2:2:end)); y2=max(frame(2:2:end));
given_prob = probability(y1:y2, x1:x2);
mu = mean(given_prob(:));

pad = zeros(size(probability));
pad(probability>mu*(1+thr))=1;
pad(y1:y2, x1:x2)=0;

[newy, newx] = ind2sub(size(pad), find(pad));
exp_x1 = min(newx); exp_x2 = max(newx);
exp_y1 = min(newy); exp_y2 = max(newy);

shrink = zeros(size(probability));
shrink(y1:y2, x1:x2) = given_prob < mu*(1-thr);
[newy, newx] = ind2sub(size(shrink), find(shrink));
shr_x1 = min(newx); shr_x2 = max(newx);
shr_y1 = min(newy); shr_y2 = max(newy);

x1 = max(min([shr_x1, exp_x1]), x1-s);
x2 = min(max([shr_x2, exp_x2]), x2+s);
y1 = max(min([shr_y1, exp_y1]), y1-s);
y2 = min(max([shr_y2, exp_y2]), y2+s);
