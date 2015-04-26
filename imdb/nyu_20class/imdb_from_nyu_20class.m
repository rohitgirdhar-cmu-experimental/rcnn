function imdb = imdb_from_nyu_20class(type)
% imdb = imdb_from_voc(root_dir, image_set, year)
%   Builds an image database for the PASCAL VOC devkit located
%   at root_dir using the image_set and year.
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

%imdb.name = 'voc_train_2007'
%imdb.image_dir = '/work4/rbg/VOC2007/VOCdevkit/VOC2007/JPEGImages/'
%imdb.extension = '.jpg'
%imdb.image_ids = {'000001', ... }
%imdb.sizes = [numimages x 2]
%imdb.classes = {'aeroplane', ... }
%imdb.num_classes
%imdb.class_to_id
%imdb.class_ids
%imdb.eval_func = pointer to the function that evaluates detections
%imdb.roidb_func = pointer to the function that returns regions of interest
root_dir = '/home/rgirdhar/Work/Projects/002_GeoObjDet/eval/NYUdevkit/';
if nargin == 0
    opts.type = 'train';
else
    opts.type = type;
end

cache_file = ['./imdb/nyu_20class/cache/imdb_' opts.type '.mat'];
try
  load(cache_file);
catch
  VOCopts = get_voc_opts_nyu20class(root_dir);
  %VOCopts.testset = image_set;

  imdb.name = ['nyu_20class'];
  imdb.image_dir = '/home/rgirdhar/Work/Projects/002_GeoObjDet/rcnn/datasets/NYU/JPEGImages';
%  fid = fopen('~/Work/Projects/002_GeoObjDet/rcnn/datasets/NYU/ImgsList.txt'); % change to train list
%  imdb.image_ids = textscan(fid, '%s');
%  imdb.image_ids = imdb.image_ids{1};
%  fclose(fid);
  load('datasets/NYU/splits.mat', 'trainNdxs', 'testNdxs');
  Ndxs = trainNdxs;
  if strcmp(opts.type, 'test')
    Ndxs = testNdxs;
  end
  imdb.image_ids = arrayfun(@(x) num2str(x), Ndxs, 'UniformOutput', false);
  imdb.extension = 'jpg';
  imdb.classes = {'bathtub', 'bed', 'bookshelf', 'box', 'chair', 'counter', 'desk', 'door', 'dresser', 'garbage-bin', 'lamp', 'monitor', 'night-stand', 'pillow', 'sink', 'sofa', 'table', 'television', 'toilet'};
  imdb.num_classes = length(imdb.classes);
  imdb.class_to_id = ...
    containers.Map(imdb.classes, 1:imdb.num_classes);
  imdb.class_ids = 1:imdb.num_classes;

  % private VOC details
  imdb.details.VOCopts = VOCopts;

  % VOC specific functions for evaluation and region of interest DB
  imdb.eval_func = @imdb_eval_nyu;
  imdb.roidb_func = @roidb_from_nyu;
  imdb.image_at = @(i) ...
      sprintf('%s/%s.%s', imdb.image_dir, imdb.image_ids{i}, imdb.extension);

  for i = 1:length(imdb.image_ids)
    tic_toc_print('imdb (%s): %d/%d\n', imdb.name, i, length(imdb.image_ids));
    info = imfinfo(imdb.image_at(i));
    imdb.sizes(i, :) = [info.Height info.Width];
  end

  fprintf('Saving imdb to cache...');
  save(cache_file, 'imdb', '-v7.3');
  fprintf('done\n');
end
