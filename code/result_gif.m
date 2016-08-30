function result_gif()
    result = load('result');
    result = result.result;
    truth = load(fullfile('..', 'car','groundtruth.txt'))+1; % maybe zero based?

    shapeInserter_b = vision.ShapeInserter('BorderColor','Custom', 'CustomBorderColor', uint8([0 0 255]));
    shapeInserter_r = vision.ShapeInserter('BorderColor','Custom', 'CustomBorderColor', uint8([255 0 0]));    

    F = uint8(zeros(272,640,3,size(result.frames,1)));
    for i=1:size(result.frames,1)
        f = result.frames(i,1);
        im = imread(fullfile('..', 'car',sprintf('%08d.jpg',f)));
        framet = truth(f,:);
        framea = result.frames(i,2:end);

        im = step(shapeInserter_b, im, int32(convert_frame_to_rect(framea)));
        im = step(shapeInserter_r, im, int32(convert_frame_to_rect(framet)));     
%         F(:,:,:,i) = im;
        
        [A,map] = rgb2ind(im,256);
        if i == 1;
            imwrite(A,map,'result.gif','gif','LoopCount',inf,'DelayTime',0);
        else
            imwrite(A,map,'result.gif','gif','WriteMode','append','DelayTime',0);
        end
    end
%     imwrite(F,'result.gif','DelayTime',0,'LoopCount',inf);
end

function rect = convert_frame_to_rect(frame1)
    x1 = min(frame1([1,3,5]));
    x2 = max(frame1([1,3,5]));
    y1 = min(frame1([2,4,6]));   
    y2 = max(frame1([2,4,6]));
    rect = [x1, y1, x2-x1, y2-y1];
end