% CIFTI2 dscalar conversion to BrainVoyager SMP files step 2.
%{ 
Dependencies
------------
1- cifti2_dscalar_to_mat.py needs to be run on beforehand.
2- Neuroelf should be added to Matlab path. Source: http://neuroelf.net/,
tested version: 1.0
3- Resulting file can be loaded to BrainVoyager together with the
corresponding surface (SRF) as a surface map (SMP).
%}
clear all;

% Load scalar maps of both hemispheres (vertex corresponce is lost) 
fname_scalars='/media/Data_Drive/ISILON/600_ATLASES/vanessen/test/scalars.mat';
sca = load(fname_scalars);

% Load both hemisphere labels file to recover vertex correspondence
fname_labels='/media/Data_Drive/ISILON/600_ATLASES/vanessen/test/Q1-Q6_RelatedParcellation210.CorticalAreas_dil_Final_Final_Areas_Group_Colors.32k_fs_LR.dlabel.nii';
lab = ft_read_cifti(fname_labels);

% Derive some parameters
[path, name, ~] = fileparts(fname_scalars);
fields = fieldnames(sca);
nr_fields = length(fields);
idx_brainstructures = unique(lab.brainstructure)';

% Loop through hemispheres
vert_idx_offset = 1;
for i=idx_brainstructures
    
    % Get relevant brain structure vertices
    idx_str = lab.brainstructure == i;
    % Get a vertex mask
    vert_idx = lab.indexmax(idx_str);
    vert_idx = isfinite(vert_idx);
    nr_verts = length(vert_idx);
    nr_used_verts = sum(vert_idx);

    % Create a default smp
    smp = xff('SMP');
    smp.NrOfVertices = nr_verts;
    
    % Loop through extracted scalar maps
    for j = 1:numel(fields)
        map = sca.(fields{j});
        temp = zeros(nr_verts, 1);
        temp(vert_idx) = map(vert_idx_offset:vert_idx_offset+nr_used_verts-1);

        % Fill in relevant smp fields
        smp.Map(j).LowerThreshold = 0.001;
        smp.Map(j).UpperThreshold = prctile(abs(map), 97.5);
        smp.Map(j).Name = fields(j);
        smp.Map(j).SMPData = temp;
        if j < nr_fields
            smp.Map(j+1) = smp.Map(j);
        end
    end
    
    % Save smp file
    smp.NrOfMaps = size(smp.Map, 1);
    identifier = lab.brainstructurelabel{i};
    out_name = fullfile(path, [name '_' identifier '.smp']);
    smp.SaveAs(out_name);
    
    % Adjust vertex offset for the next hemisphere
    vert_idx_offset = vert_idx_offset + nr_used_verts;
end

disp('Finished.')

