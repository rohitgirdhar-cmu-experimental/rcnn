annotdir = '/home/rgirdhar/Work/Projects/002_GeoObjDet/rcnn/datasets/NYU/Labels_20class/';
outxmlannotdir = '/home/rgirdhar/Work/Projects/002_GeoObjDet/eval/NYUdevkit/NYU/Annotations_20class/';
classes = {'bathtub', 'bed', 'bookshelf', 'box', 'chair', 'counter', 'desk', 'door', 'dresser', 'garbage-bin', 'lamp', 'monitor', 'night-stand', 'pillow', 'sink', 'sofa', 'table', 'television', 'toilet', 'None'};
% classes = {'bed','chair','monitortv','sofa','table', 'None'}; % check

for i = 1 : 1449
  try
    boxes = dlmread(fullfile(annotdir, [num2str(i) '.txt']));
  catch
    boxes = [size(classes, 2),1,1,1,1];
  end
  % first term is the class, and the last 2 columns should be xmax ymax
  boxes(:, 4) = boxes(:, 2) + boxes(:, 4);
  boxes(:, 5) = boxes(:, 3) + boxes(:, 5);
  docNode = com.mathworks.xml.XMLUtils.createDocument('annotation');
  docRootNode = docNode.getDocumentElement;
  foldername = docNode.createElement('folder');
  foldername.appendChild(docNode.createTextNode('NYU'));
  docRootNode.appendChild(foldername);
  filename = docNode.createElement('filename');
  filename.appendChild(docNode.createTextNode(sprintf('%d.jpg', i)));
  docRootNode.appendChild(filename);
  sizenode = docNode.createElement('size');
  widthnode = docNode.createElement('width');
  widthnode.appendChild(docNode.createTextNode(sprintf('%d', 640)));
  sizenode.appendChild(widthnode);
  widthnode = docNode.createElement('height');
  widthnode.appendChild(docNode.createTextNode(sprintf('%d', 480)));
  sizenode.appendChild(widthnode);
  widthnode = docNode.createElement('depth');
  widthnode.appendChild(docNode.createTextNode(sprintf('%d', 3)));
  sizenode.appendChild(widthnode);
  docRootNode.appendChild(sizenode);
  seg = docNode.createElement('segmented');
  seg.appendChild(docNode.createTextNode('1'));
  docRootNode.appendChild(seg);

  for j = 1 : size(boxes, 1)
    object = docNode.createElement('object');
    objname = docNode.createElement('name');
    objname.appendChild(docNode.createTextNode(sprintf('%s', classes{boxes(j, 1)})));
    bndbox = docNode.createElement('bndbox');
    xmin = docNode.createElement('xmin');
    xmin.appendChild(docNode.createTextNode(sprintf('%d', boxes(j, 2))));
    bndbox.appendChild(xmin);


    ymin = docNode.createElement('ymin');
    ymin.appendChild(docNode.createTextNode(sprintf('%d', boxes(j, 3))));
    bndbox.appendChild(ymin);


    xmax = docNode.createElement('xmax');
    xmax.appendChild(docNode.createTextNode(sprintf('%d', boxes(j, 4))));
    bndbox.appendChild(xmax);


    ymax = docNode.createElement('ymax');
    ymax.appendChild(docNode.createTextNode(sprintf('%d', boxes(j, 5))));
    bndbox.appendChild(ymax);

    object.appendChild(objname);
    object.appendChild(bndbox);
    docRootNode.appendChild(object);
  end
  xmlwrite(fullfile(outxmlannotdir, [num2str(i) '.xml']), docNode);
end
