function genImgsAndLabs()
load('nyu_depth_v2_labeled.mat');
load('splits.mat');

% names = {'bed', 'chair', 'mtv', 'sofa', 'table'};
ids = {[157], [5], [49, 172], [83], [19]};
myids = {[1], [2], [3], [4], [5]};

imgsdir = 'JPEGImages';
labelsdir = 'Labels';

for i = 1 : size(images, 4) 
    fprintf(2, 'Doing for %d\n', i);
    I = images(:, :, :, i);
    imwrite(I, fullfile(imgsdir, [num2str(i) '.jpg']));
    label = labels(:, :, i);
    fid = fopen(fullfile(labelsdir, [num2str(i) '.txt']), 'w');
    for j = 1 : numel(myids)
        bboxes = getObjDets(label, ids{j});
        for k = 1 : size(bboxes, 1)
            fprintf(fid, '%d %f %f %f %f\n', myids{j}, bboxes(k, 1), ...
                    bboxes(k, 2), bboxes(k, 3), bboxes(k, 4));
        end
    end
    fclose(fid);
end

function bboxes = getObjDets(labelImg, ids)
bboxes = zeros(0, 4);
for id = ids(:)'
    r = regionprops(labelImg == id, 'BoundingBox');
    thisbbxs = cat(1, r.BoundingBox);
    if size(thisbbxs, 1) >= 1
        bboxes(end + 1 : end + size(thisbbxs, 1), :) = thisbbxs;
    end
end

