% for ransac
% x : 14x4 matrix. each column is [s1; s2; l1; l2]'
% H : homography that warp 1 coords to 2 coords. i,e., l1 = H'*l2, or x2 =
%     H*x1
function H = ransac_fit_homography4l(x)

l1 = x(9:11,:)'; 
l2 = x(12:14,:)';
H = fit_homography4l(l1,l2);

if isnan(H)
    H=[];
end
