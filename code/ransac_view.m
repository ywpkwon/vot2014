% we got T

pp1=p1';
pp2=p2';
pp1_ = T*[pp1; ones(1,size(pp1,2))];
pp1_ = pp1_(1:2,:)./repmat(pp1_(3,:),2,1);

figure; imshow(im1); hold on;
scatter(pp1(1,:),pp1(2,:),'r.'); 
plot([pp1(1,:); pp2(1,:)], [pp1(2,:); pp2(2,:)],'r-');
scatter(pp2(1,:),pp2(2,:),'r.'); 
hold on;
scatter(pp1_(1,:),pp1_(2,:),'b.');
plot([pp1_(1,:); pp2(1,:)], [pp1_(2,:); pp2(2,:)],'g-');

hold on;
scatter(pp1_(1,inliers),pp1_(2,inliers),'fill');
axis ij

allp = [pp1 pp2 pp1_];
axis([min(allp(1,:))-1 max(allp(1,:))+1 min(allp(2,:))-1 max(allp(2,:))+1]);
draw_frame(frame1,'r');
draw_frame(frame2,'b');