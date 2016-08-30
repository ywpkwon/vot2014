function result = optical_multiple_frame
    addpath('ransac');
    truth = load(fullfile('..', 'car','groundtruth.txt'))+1; % maybe zero based?
    
    i=1;
    im1 = imread(fullfile('..', 'car',sprintf('%08d.jpg',i)));
    frame1 = truth(i,:);

    shapeInserter_b = vision.ShapeInserter('BorderColor','Custom', 'CustomBorderColor', uint8([0 0 255]));
    shapeInserter_r = vision.ShapeInserter('BorderColor','Custom', 'CustomBorderColor', uint8([255 0 0]));
    
    result.frames = [i frame1];
    result.prob = zeros(size(im1,1), size(im1,2), 255);
    result.T = zeros(3, 3, 255);
    
    % object
    palette = im1;
    prob_prev = zeros(272, 640);
    
    while i<249  
        tic; 
        %% search parameters  
        x1 = min(frame1([1,3,5])); x2 = max(frame1([1,3,5]));
        y1 = min(frame1([2,4,6])); y2 = max(frame1([2,4,6]));
        frame_width = x2-x1;
        frame_height = y2-y1;
      
        xs = linspace(x1-ceil(0.05*frame_width), x2+ceil(0.05*frame_width), 20);      % x samples in frame
        ys = linspace(y1-ceil(0.05*frame_height), y2+ceil(0.05*frame_height),10);      % x samples in frame
        xs = unique(round(xs));
        ys = unique(round(ys));
        
        %% rough T with palette
        check_frames = [i+1, i+2, i+3, i+4, i+5];
        check=[];
        for j=1:numel(check_frames)
            check(j).im = imread(fullfile('..', 'car', sprintf('%08d.jpg', check_frames(j))));
            [p1, p2, nndr] = get_flow(palette, check(j).im, xs, ys); 
            [~, sind] = sort(nndr);
            check(j).p1 = p1(nndr<nndr(sind(floor(numel(nndr)/2))),:);
            check(j).p2 = p2(nndr<nndr(sind(floor(numel(nndr)/2))),:);
            [check(j).T, check(j).inliers] = get_transformation(check(j).p1, check(j).p2, check_frames(j)-i);
        end      
        
        %% refine T from rough T
        xs = linspace(x1-ceil(0.05*frame_width), x2+ceil(0.05*frame_width), 30);      % x samples in frame
        ys = linspace(y1-ceil(0.05*frame_height), y2+ceil(0.05*frame_height),20);      % x samples in frame
        xs = unique(round(xs));
        ys = unique(round(ys));

        for j=1:numel(check_frames)
            [p1, p2] = get_fine_flow(im1, check(j).im, xs, ys, check(j).T);   %search*(check_frames(j)-i)
%             [~, sind] = sort(nndr);
%             check(j).p1 = p1(nndr<nndr(sind(floor(numel(nndr)/2))),:);
%             check(j).p2 = p2(nndr<nndr(sind(floor(numel(nndr)/2))),:);
            check(j).p1 = p1;
            check(j).p2 = p2;
            [check(j).T, check(j).inliers] = get_transformation(check(j).p1, check(j).p2, 2);
        end

        %% find overall T from propotional optical flow
        frame_offset = check_frames-i;
        frame_offset = frame_offset(1)./frame_offset;
        
        p1 = cell(size(check));
        p2 = cell(size(check));
        for j=1:numel(check_frames)
            p1{j}=check(j).p1(check(j).inliers,:); 
            p2{j}=check(j).p1(check(j).inliers,:)+(check(j).p2(check(j).inliers,:)-check(j).p1(check(j).inliers,:))*frame_offset(j); 
        end
        all_p1 = vertcat(p1{:});
        all_p2 = vertcat(p2{:});       
        [T, inliers] = get_transformation(all_p1, all_p2, 1); 
        
        %% assign frame2
        frame2 = transform_frame(frame1, T);
        
        %% concensus map
        map = zeros(272,640,numel(check));
        for j=1:numel(check)
            map(:,:,j) = concensus_map(check(j).p1(check(j).inliers,1), check(j).p2(check(j).inliers,2));
        end           
        prob = sum(map,3)/size(map,3);

        %% object palette
        [palette_new, prob_new] = update_palette(palette, T, im1, prob, prob_prev);
        
        if false,   % for debugging purpose
            figure(1); imshow(im1); hold on; cl='rgbckyrgbcky';
            for j=1:numel(p1)
                plot([p1{j}(:,1) p2{j}(:,1)]', [p1{j}(:,2) p2{j}(:,2)]', cl(j));
            end
            axis([frame1(1)-2 frame1(5)+2 frame1(4)-2 frame1(2)+2]);
            
            figure(2); 
            subplot(2,1,1); imshow(im1); hold on; draw_frame(frame1,'r'); axis([frame1(1)-10 frame1(5)+10 frame1(4)-10 frame1(2)+10]); axis on,
            draw_frame(framec,'c');
            subplot(2,1,2); imshow(check(1).im); hold on; draw_frame(frame2,'r'); axis([frame1(1)-10 frame1(5)+10 frame1(4)-10 frame1(2)+10]); axis on,
            draw_frame(framec2,'c');
            
            figure(3); 
            h1=subplot(121); imshow(im1);
            axis([xs(1)-20 xs(end)+20 ys(1)-20 ys(end)+20]);
            h2=subplot(122); contourf(prob); axis ij equal off;
            axis([xs(1)-20 xs(end)+20 ys(1)-20 ys(end)+20]);
            p1 = get(h1, 'pos');
            p2 = get(h2, 'pos'); p2(1)=p1(1)+p1(3);
            set(h2, 'pos', p2);

            figure(4); imshow(im1); hold on; cl='rgbck';
            for j=1:numel(check)
                            quiver(check(j).p1(check(j).inliers,1), check(j).p1(check(j).inliers,2), check(j).p2(check(j).inliers,1)-check(j).p1(check(j).inliers,1), check(j).p2(check(j).inliers,2)-check(j).p1(check(j).inliers,2),cl(j),'autoscale','off');
            end
            axis([xs(1)-2 xs(end)+2 ys(1)-2 ys(end)+2]);
            legend({'flow to +1 frame', 'flow to +2 frame', 'flow to +3 frame', 'flow to +4 frame', 'flow to +5 frame'});
            
            figure(5); imshow(palette_new);
            keyboard
        end
        
        palette = palette_new;
        prob_prev = prob_new;
        
        next_frame = frame2;
        
        %% record output
        next_i = check_frames(1);
        result.frames = [result.frames; next_i round(next_frame)];
        result.prob(:,:,i) = prob;
        result.T(:,:,i) = T;
        
        %% save output image
        outim = step(shapeInserter_b, check(1).im, int32(convert_frame_to_rect(next_frame)));
        outim = step(shapeInserter_r, outim, int32(convert_frame_to_rect(truth(next_i,:))));     
        outf = fullfile('..', 'output', sprintf('%08d.jpg',check_frames(1)));
        imwrite(outim, outf);
        fprintf('%d done.. %.3f\n', i, performance(result.frames(end,:)));
        
        if mod(i,5)==0,
            save('result', 'result');
            fprintf('saved.\n');
        end
        
        %% update
        im1 = check(1).im;
        frame1 = next_frame;
        i = next_i;
    end
    
    save('result', 'result');
    fprintf('saved.\n');
    performance(result.frames);
    toc;
end

function [T, inliers] = get_transformation(p1,p2, thr)
    X = [p1'; p2'];
    maxDataTrials = 20; maxTrials= 30000; feedback = false; degenfn = @(x) false;
    [T, inliers] = ransac(X, @fit_affine3, @ransac_homo_distfn, degenfn, 3, thr, feedback, maxDataTrials, maxTrials);                       
    if numel(inliers)<5, keyboard, end;
end

function frame_ = transform_frame(frame, T)
    frame_ = T*[reshape(frame, [2,4]); ones(1,4)];
    frame_ = frame_(1:2,:)./repmat(frame_(3,:),2,1);
    frame_ = frame_(:)';
    frame_([1,3]) = sum(frame_([1,3]))/2;    %x1
    frame_([2,8]) = sum(frame_([2,8]))/2;    %x2
    frame_([5,7]) = sum(frame_([5,7]))/2;    %y1
    frame_([4,6]) = sum(frame_([4,6]))/2;    %y2
end

function rect = convert_frame_to_rect(frame1)
    x1 = min(frame1([1,3,5]));
    x2 = max(frame1([1,3,5]));
    y1 = min(frame1([2,4,6]));   
    y2 = max(frame1([2,4,6]));
    rect = [x1, y1, x2-x1, y2-y1];
end
