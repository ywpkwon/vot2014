% H=computeH(im1_pts, im2_pts, model)
% computes homography/affine matrix from the control point pairs
% in least squares manner.
% - im1_pts, im2_pts : n x 2 matrix
% - H : 3 x 3 matrix
%
% implemeted by youngwook Kwon
%

function T=computeH(im1_pts, im2_pts, model)
if nargin<3,
    model = 'projective';
end

assert(isequal(size(im1_pts), size(im2_pts)));

H = zeros(3,3);
switch (model)
    case 'projective'
        % HOMOGRAPHY: overdetermined solution Ax=b. min |Ax-b|.
        P1 = [im1_pts ones(size(im1_pts,1),1)];
        A = zeros(2*size(im1_pts,1), 8);
        for i=1:size(im1_pts,1)
            A(2*(i-1)+1:2*i,:) = [P1(i,:) zeros(1,3) -im2_pts(i,1)*P1(i,1:2); zeros(1,3) P1(i,:) -im2_pts(i,2)*P1(i,1:2)];
        end
        b = im2_pts';
        b = b(:);
        
        if abs(cond(A))>1e+13, T=[]; return; end
        
        x = A\b;
        T = [x(1:3)'; x(4:6)'; x(7:8)' 1];
    case 'affine'
        % AFFINE: overdetermined solution Ax=b. min |Ax-b|.
        % [x1 y1 1 0 0 0; 0 0 0 x1 y1 1] * [a1 a2 a3 a4 a5 a6]' = [x1'; y1'];
        P1 = [im1_pts ones(size(im1_pts,1),1)];
        A = zeros(2*size(im1_pts,1), 6);
        for i=1:size(im1_pts,1)
            A(2*(i-1)+1:2*i,:) = [P1(i,:) zeros(1,3); zeros(1,3) P1(i,:)];
        end
        b = im2_pts';
        b = b(:);
        
        if abs(cond(A))>1e+13, T=[]; return; end
        
        x = A\b;
        T = [x(1:3)'; x(4:6)'; 0 0 1];
    case 'similarity'
        try
            tform = fitgeotrans(im1_pts,im2_pts,'similarity');
            T = tform.T';
        catch
            T = [];
        end
end




