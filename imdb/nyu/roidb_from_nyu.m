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
    matlabpool open 8;
  catch
  end
  %parfor i = 1:length(imdb.image_ids)
  parfor i = 1:length(imdb.image_ids)
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
    [cls, gtb] = readBoxes(fullfile('~/Work/Projects/002_GeoObjDet/rcnn/datasets/NYU/Labels', ...
                [num2str(image_id) '.txt']));
    % add the GTs
    s_gt = [];
    s_overlap = [];
    s_boxes = [];
    s_feat = [];
    s_class = [];
    for i = 1 : size(gtb, 1)
        s_gt(end + 1) = 1;
        s_overlap(end + 1, 1:5) = 0;
        s_overlap(end, cls(i)) = 1;
        s_boxes(end + 1, :) = gtb(i, :);
        s_class(end + 1) = cls(i);
    end
    for i = 1 : size(selb, 1)
        s_gt(end + 1) = 0;
        s_boxes(end + 1, :) = selb(i, :);
        s_class(end + 1) = int32(getClass(selb(i, :), gtb, cls));
        s_overlap(end + 1, 1 : 5) = 0;
        if s_class(end) ~= 0
            s_overlap(end, s_class(end)) = 1;
        end
    end
    rec.gt = s_gt;
    rec.overlap = s_overlap;
    rec.boxes = s_boxes;
    rec.feat = s_feat;
    rec.class = s_class;
end
                 
function [cls, boxes] = readBoxes(fpath)
fid = fopen(fpath);
data = textscan(fid, '%d %f %f %f %f');
cls = data{1};
boxes = cat(2, data{2}, data{3}, data{2} + data{4}, data{3} + data{5});
fclose(fid);

function cls = getClass(box, gtboxes, gtclasses)
mxOverlap = 0;
cls = 0;
for i = 1 : size(gtboxes, 1)
    ov = computeOverlap(box, gtboxes(i, :));
    if mxOverlap < ov
        mxOverlap = ov;
        cls = gtclasses(i);
    end
end
cls = int32(cls);

function over = computeOverlap(a, b)
% both are rectangles in xmin ymin xmax ymax
over = rectint([a(1) a(2) a(3) - a(1) a(4) - a(2)], [b(1) b(2) b(3) - b(1) b(4) - b(2)]);


