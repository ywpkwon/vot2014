% for ransac
% x : 4x3 matrix.
% H : homography that warp 1 coords to 2 coords. 
function M = fit_affine3(x)

p1=x(1:2,:);
p2=x(3:4,:);
M=computeH(p1',p2','affine');

% if isempty(M),
%     return;
% else
%     dof = decompose_affine_t(M);
%     if abs(dof.sx-dof.sy)>0.01, 
%         M=[]; 
%     end
% end

% limit.translatex = [-100 100];
% limit.translatey = [-100 100];
% limit.rotation = [0 2*pi];
% limit.scalex = [1/2 2];
% limit.scaley = [1/2 2];
% limit.skew = [0.98 0.02];
