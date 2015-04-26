function VOCopts = get_voc_opts_nyu20class(path)

tmp = pwd;
cd(path);
try
  addpath('VOCcode');
  VOCinit;
catch e
  disp(getReport(e));
  rmpath('VOCcode');
  cd(tmp);
  error(sprintf('VOCcode directory not found under %s', path));
end
rmpath('VOCcode');
cd(tmp);
VOCopts.annopath = strrep(VOCopts.annopath, '/Annotations/', '/Annotations_20class/');
