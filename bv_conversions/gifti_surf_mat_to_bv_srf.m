% Gifti surface to BrainVoyager SRF format conversion step 2.
%{ 
Dependencies
------------
1- gifti_surf_to_mat.py needs to be run on the gifti surface file
beforehand.
2- Neuroelf should be added to Matlab path. Source: http://neuroelf.net/,
tested version: 1.0
3- Resulting file can be loaded to BrainVoyager using a dummy VMR file
(eg. empty vmr, or a random subject).
%}
clear all;

% Load extracted gifti mesh mat file
fname_giftimat = '/media/Data_Drive/ISILON/600_ATLASES/vanessen/test/Q1-Q6_RelatedParcellation210.L.midthickness_MSMAll_2_d41_WRN_DeDrift.32k_fs_LR.mat';
gmat = load(fname_giftimat);

% Derived parameters
[path, name, ~] = fileparts(fname_giftimat);
verts = gmat.vertices;
faces = gmat.faces;
norma = gmat.normals;
nr_verts = size(verts, 1);
nr_faces = size(faces, 1);
center = 127.75;
range = max(verts(:)) - min(verts(:));
mid = mean(verts, 1);
verts(:, 1) = verts(:, 1) + center - mid(1);
verts(:, 2) = verts(:, 2) + center - mid(2);
verts(:, 3) = verts(:, 3) + center - mid(3);
vert_rgb = zeros(nr_verts, 4) + 150;
vert_rgb(:, 1) = nan(nr_verts, 1);

% Create a surface file
srf = xff('SRF');
srf.ExtendedNeighbors = 2;
srf.NrOfVertices = nr_verts;
srf.NrOfTriangles = nr_faces;
srf.MeshCenter = [center center center];
srf.VertexCoordinate = double(verts);
srf.VertexNormal = double(norma);
srf.VertexColor = vert_rgb;
srf.TriangleVertex = double(faces);

% If there are incorrect/missing normals, use this function
% srf = srf.RecalcNormals;

% Correct neighbours field is required for shading, otherwise you will see
% random black patches etc.
srf = srf.UpdateNeighbors; 

% Save
fname_out = fullfile(path, [name '.srf']);
srf.SaveAs(fname_out);
disp('Finished')
