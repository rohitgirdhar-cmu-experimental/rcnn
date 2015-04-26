function visResults(test_imdb, class_name, cache_name, outdir)
cachedir = 'cachedir/nyu/';
load(fullfile(cachedir, [class_name '_boxes_' cache_name '.mat']), 'boxes');
for i = 1 : numel(test_imdb.image_ids)
  imid = test_imdb.image_ids{i};
  I = imread(fullfile(test_imdb.image_dir, [imid '.' test_imdb.extension]));
  thisboxes = boxes{i}(:, 1:4);
  scores = boxes{i}(:, 5);
  thisboxes(scores < -0.5, :) = [];
  thisoutdir = fullfile(outdir, cache_name, class_name);
  unix(['mkdir -p ' thisoutdir]);
  showboxes2(I, thisboxes, fullfile(thisoutdir, [imid '.jpg']));
end

