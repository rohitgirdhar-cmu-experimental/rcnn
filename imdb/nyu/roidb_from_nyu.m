function roidb = roidb_from_nyu(imdb)
% roidb = roidb_from_voc(imdb)
%   Builds an regions of interest database from imdb image
%   database. Uses precomputed selective search boxes available
%   in the R-CNN data package.
%
%   Inspired by Andrea Vedaldi's MKL imdb and roidb code.

% AUTORIGHTS
% ---------------------------------------------------------
% Copyright (c) 2014, Ross Girshick
% 
% This file is part of the R-CNN code and is available 
% under the terms of the Simplified BSD License provided in 
% LICENSE. Please retain this notice and LICENSE if you use 
% this file (or any portion of it) in your project.
% ---------------------------------------------------------

cache_file = ['./imdb/nyu/cache/roidb_' imdb.name];
try
  load(cache_file);
catch
%  VOCopts = imdb.details.VOCopts;

%  addpath(fullfile(VOCopts.datadir, 'VOCcode')); 

  roidb.name = imdb.name;

  fprintf('Loading region proposals...');
  regions_file = './data/nyu_selsearch_boxes.mat';
  regions = load(regions_file);
  fprintf('done\n');

  try
    matlabpool open 4;
  catch
  end
  %parfor i = 1:length(imdb.image_ids)
  for i = 1:length(imdb.image_ids)
    tic_toc_print('roidb (%s): %d/%d\n', roidb.name, i, length(imdb.image_ids));
    r = attach_proposals(regions.boxes, imdb.image_ids(i));
    rois(i) = r;
  end
  roidb.rois = rois;

%  rmpath(fullfile(VOCopts.datadir, 'VOCcode')); 

  fprintf('Saving roidb to cache...(%s)', cache_file);
  save(cache_file, 'roidb', '-v7.3');
  fprintf('done\n');
end


% ------------------------------------------------------------------------
function rec = attach_proposals(boxes, image_ids)
% ------------------------------------------------------------------------
DEBUG = 1;
% change selective search order from [y1 x1 y2 x2] to [x1 y1 x2 y2]
%boxes = boxes(:, [2 1 4 3]);

%           gt: [2108x1 double]
%      overlap: [2108x20 single]
%      dataset: 'voc_2007_trainval'
%        boxes: [2108x4 single]
%         feat: [2108x9216 single]
%        class: [2108x1 uint8]

% here image_ids are numbers, so convert

image_ids = cellfun(@(x) str2num(x), image_ids);
for image_id = image_ids(:)'
    selb = boxes{image_id};
    selb = selb(:, [2 1 4 3]); % fix to (x1 y1 x2 y2)
    [gt_classes, gtb] = readBoxes(fullfile('~/Work/Projects/002_GeoObjDet/rcnn/datasets/NYU/Labels', ...
                [num2str(image_id) '.txt']));
    gtb = int32(gtb);
    selb = int32(selb);
    if DEBUG
        I = imread(fullfile('~/Work/Projects/002_GeoObjDet/rcnn/datasets/NYU/JPEGImages/', [num2str(image_id) '.jpg']));
        boxes_to_dump = gtb;
        for i = 1 : size(boxes_to_dump, 1)
            clip = I(boxes_to_dump(i, 2) : boxes_to_dump(i, 4), ...
                boxes_to_dump(i, 1) : boxes_to_dump(i, 3), :);
            imwrite(clip, fullfile('~/Work/Projects/002_GeoObjDet/rcnn/imdb/nyu/dump/', ['ss_' num2str(image_id) '_' num2str(i) '.jpg']));
        end
    end

    all_boxes = cat(1, gtb, selb);
    num_gt_boxes = size(gtb, 1);
    num_boxes = size(selb, 1);
    rec.gt = cat(1, true(num_gt_boxes, 1), false(num_boxes, 1));
    rec.overlap = zeros(num_gt_boxes + num_boxes, 5);
    for i = 1 : num_gt_boxes
        rec.overlap(:, gt_classes(i)) = ...
            max(rec.overlap(:, gt_classes(i)), boxoverlap(all_boxes, gtb(i, :)));
    end
    rec.boxes = single(all_boxes);
    rec.feat = [];
    rec.class = uint8(cat(1, gt_classes, zeros(num_boxes, 1)));
end
                 
function [cls, boxes] = readBoxes(fpath)
fid = fopen(fpath);
data = textscan(fid, '%d %f %f %f %f');
cls = data{1};
boxes = cat(2, data{2}, data{3}, data{2} + data{4}, data{3} + data{5});
fclose(fid);

function [cls, overlaps] = getClass(box, gtboxes, gtclasses)
mxOverlap = 0;
cls = 0;
overlaps = zeros(1, 5);
for i = 1 : size(gtboxes, 1)
    ov = computeOverlap(box, gtboxes(i, :));
    overlaps(gtclasses(i)) = max(ov, overlaps(gtclasses(i)));
end
[mval, cls] = max(overlaps);
if mval == 0
    cls = 0;
end
cls = int32(cls);

function over = computeOverlap(a, b)
% both are rectangles in xmin ymin xmax ymax
inter = rectint([a(1) a(2) a(3) - a(1) a(4) - a(2)], [b(1) b(2) b(3) - b(1) b(4) - b(2)]);
gt = (b(3) - b(1)) * (b(4) - b(2));
over = inter ./ gt;

