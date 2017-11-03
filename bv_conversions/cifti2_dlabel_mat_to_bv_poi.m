% CIFTI2 label conversion to BrainVoyager POI files step 2.
%{
Dependencies
------------
1- connectome_borders_xml_to_mat.py should be run beforehand.
2- Neuroelf should be added to Matlab path. Source: http://neuroelf.net/,
tested version: 1.0
3- 'cifti-matlab' library sould be added to Matlab path. Source: 
https://github.com/Washington-University/cifti-matlab, tested version: 
Apr 16, 2016.
4- Resulting file can be loaded to BrainVoyager with SRF files as pathes of
interest (POI) file.
%}
clear all;

% Can load separate or both hemisphere .dlabels.nii
fname_labels='/media/Data_Drive/ISILON/600_ATLASES/vanessen/test/Q1-Q6_RelatedParcellation210.L.CorticalAreas_dil_Colors.32k_fs_LR.dlabel.nii';
lab = ft_read_cifti(fname_labels);

% Load corresponding extracted label descriptions. (Caution!) Make sure to
% have extracted labels in the same order as label indices.
mat_fname = '/media/Data_Drive/ISILON/600_ATLASES/vanessen/test/Q1-Q6_RelatedParcellation210.L.CorticalAreas_dil_Final_Final_Areas_Group_Colors.32k_fs_LR_POI_labels.mat';
label_desc = load(mat_fname);

% Derive some parameters
[path, name, ~] = fileparts(fname_labels);
idx_brainstructures = unique(lab.brainstructure)';
fields = fieldnames(lab);
parcel_field = fields{2};

% Loop through hemispheres
for i=idx_brainstructures

    % Get relevant brain structure vertices
    idx_str = lab.brainstructure == i;
    % Get labels
    label_verts = lab.(parcel_field)(idx_str);
    % Swap nans with 0 (this indicates masked out vertices)
    label_verts(isnan(label_verts)) = 0;
    labels = unique(label_verts);
    % Remove the masked out regions
    labels = labels(2:end);

    % Derive some parameters
    nr_labels = length(labels);
    nr_verts = length(label_verts);
    verts = linspace(1, nr_verts, nr_verts);

    % Create a default BV poi
    poi = xff('POI');
    poi.NrOfMeshVertices = length(label_verts);
    poi.NrOfPOIs = nr_labels;

    % Populate POI field
    for j = 1:nr_labels
        l = labels(j);
        % Fill name and color fields
        poi.POI(j).Name = label_desc.label_names(j, :);
        poi.POI(j).Color = label_desc.label_colors(j, :);
        % Get labeled vertex indices
        poi.POI(j).Vertices = verts(label_verts==l);
        % Create a new POI until the last label
        if j < nr_labels
            poi.POI(j+1) = poi.POI(j);
        end
    end

    % Save
    identifier = lab.brainstructurelabel{i};
    fname_out = fullfile(path, [name '_' identifier '.poi']);
    poi.SaveAs(fname_out);
end

disp('Finished.')
