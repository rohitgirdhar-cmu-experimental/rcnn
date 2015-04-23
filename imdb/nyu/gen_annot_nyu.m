annotdir = '~/Work/Projects/002_GeoObjDet.old/3dObjectDetection/rcnn/datasets/NYU/Labels/';
outxmlannotdir = '/home/rgirdhar/Work/Projects/002_GeoObjDet.old/3dObjectDetection/rcnn/datasets/NYUdevkit/NYU/Annotations/';
classes = {'bed','chair','monitortv','sofa','table'}; % check

for i = 1 : 1449
%  boxes = dlmread(fullfile(annotdir, [num2str(i) '.txt']));
  docNode = com.mathworks.xml.XMLUtils.createDocument('annotation');
  docRootNode = docNode.getDocumentElement;
  foldername = docNode.createElement('folder');
  foldername.appendChild(docNode.createTextNode('NYU'));
  docRootNode.appendChild(foldername);
  filename = docNode.createElement('filename');
  filename.appendChild(docNode.createTextNode(sprintf('%d.jpg', i)));
  docRootNode.appendChild(filename);

  for j = 1 : size(boxes, 1)
    object = docNode.createElement('object');
    objname = docNode.createElement('name');
    objname.appendChild(docNode.createTextNode(sprintf('%s', classes{boxes(j, 1)})));
    bndbox = docNode.createElement('bndbox');
    xmin = docNode.createElement('xmin');
    xmin.appendChild(docNode.createTextNode(sprintf('%f', boxes(j, 1))));
    bndbox.appendChild(xmin);


    ymin = docNode.createElement('ymin');
    ymin.appendChild(docNode.createTextNode(sprintf('%f', boxes(j, 2))));
    bndbox.appendChild(ymin);


    xmax = docNode.createElement('xmax');
    xmax.appendChild(docNode.createTextNode(sprintf('%f', boxes(j, 3))));
    bndbox.appendChild(xmax);


    ymax = docNode.createElement('ymax');
    ymax.appendChild(docNode.createTextNode(sprintf('%f', boxes(j, 4))));
    bndbox.appendChild(ymax);

    object.appendChild(objname);
    object.appendChild(bndbox);
    docRootNode.appendChild(object);
  end
  xmlwrite(fullfile(outxmlannotdir, [num2str(i) '.txt']), docNode);
end
