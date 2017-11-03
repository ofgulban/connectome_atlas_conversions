"""CIFTI2 labels conversion to BrainVoyager POI files step 1."""

import os
import xml.etree.ElementTree as ET
from scipy.io import savemat

fname_xml = '/path/to/Q1-Q6_RelatedParcellation210.L.CorticalAreas_dil_Final_Final_Areas_Group_Colors.32k_fs_LR.border'
basename = os.path.basename(fname_xml).split('.')[0:-1]
basename = '.'.join(basename)
dirname = os.path.dirname(fname_xml)

# XML parsing
tree = ET.parse(fname_xml)
root = tree.getroot()

label_names, label_colors = [], []
for r in range(len(root[1])):  # loop through region labels

    # Get label fields
    label = root[1][r].attrib
    label_names.append((label['Name']))

    # Scale colors to uint8 range
    color = [float(label['Red']), float(label['Green']), float(label['Blue'])]
    color = [int(c*255) for c in color]
    label_colors.append(color)

# Save
mat = dict()
mat['label_names'] = label_names
mat['label_colors'] = label_colors
fname_out = os.path.join(dirname, basename + '_POI_labels.mat')
savemat(fname_out, mat)
