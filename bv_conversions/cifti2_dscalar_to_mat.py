"""CIFTI2 dscalar conversion to BrainVoyager SMP files step 1.

Notes
-----
1- cifti_matlab (source: https://github.com/Washington-University/cifti-matlab,
tested version: Apr 16, 2016) fails to read dscalar.nii files.
2- Nibabel cifti2 reader has some issues (v2.2.0) and does not read NaN values.
However the information which can be read is still useful and can be converted
to Brainvoyager SMP's by borrowing information form dlabel.nii files in Matlab.
3- Upon running this script, there will be the following warning:
'pixdim[1,2,3] should be non-zero; setting 0 dims to 1'. This can be ignored.

"""

from scipy.io import savemat
from nibabel.cifti2 import load

fname_myel = '/path/to/Q1-Q6_RelatedParcellation210.MyelinMap_BC_MSMAll_2_d41_WRN_DeDrift.32k_fs_LR.dscalar.nii'
fname_curv = '/path/to/Q1-Q6_RelatedParcellation210.curvature_MSMAll_2_d41_WRN_DeDrift.32k_fs_LR.dscalar.nii'
fname_thic = '/path/to/Q1-Q6_RelatedParcellation210.corrThickness_MSMAll_2_d41_WRN_DeDrift.32k_fs_LR.dscalar.nii'

# Enter the name for the output mat file
fname_out = '/path/to/scalars.mat'

# load cifti images (not reading correctly but good enough to extract maps)
myel = load(fname_myel)
curv = load(fname_curv)
thic = load(fname_thic)

# save the maps to be used with neuroelf
mat = dict()
mat['myelin'] = myel.get_data()
mat['curvature'] = curv.get_data()
mat['cortical_thickness'] = thic.get_data()
savemat(fname_out, mat)
print('Finished.')
