function compute_boxes()
% Compute the selective search boxes for each image in the dpath and store into a mat
imgsDir = '~/Work/Projects/002_GeoObjDet/rcnn/datasets/NYU/JPEGImages';
imgsList = '~/Work/Projects/002_GeoObjDet/rcnn/datasets/NYU/ImgsList.txt';

addpath(genpath('SelectiveSearchCodeIJCV'));

fid = fopen(imgsList);
lst = textscan(fid, '%s\n');
lst = lst{1};
fclose(fid);

try
    matlabpool open 6;
catch
end
parfor i = 1 : numel(lst)
    impath_str = lst{i};
    I = imread(fullfile(imgsDir, impath_str));
    boxes{i} = selective_search_boxes(I, true, 512);
    fprintf('Done for %d\n', i);
end

disp('Saving to disk');
save('../data/nyu_selsearch_boxes.mat', 'boxes', '-v7.3');
%saveTxt('nyu_selsearch_boxes/', boxes);

function saveTxt(dpath, boxes)
mkdir(dpath);
for i = 1 : numel(boxes)
    dlmwrite(fullfile(dpath, [num2str(i) '.txt']), boxes{i});
end
