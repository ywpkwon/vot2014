% for ransac
% x : 4x3 matrix. [x1 y1 x2 y2]' x 3 columns

function M = ransac_3pts_affine(x)

p1 = x(1:2,:)'; % row vec
p2 = x(3:4,:)';
try
    tform = fitgeotrans(p1,p2,'affine');
    M= tform.T';
catch me
    disp('skip error');
    M=[];
end