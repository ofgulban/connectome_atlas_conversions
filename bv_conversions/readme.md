# Glasser et al. 2016 atlas conversions processing steps

__Beware!__ work in progress...

## 1. Convert surfaces to BV surface format:

1. run ```gifti_surf_to_mat.py```
2. run ```gifti_surf_mat_to_bv_srf.m```

## 2. Convert parcels to BV patches of interest format:

1. run ```connectome_borders_xml_to_mat.py```
2. run ```cifti2_dlabel_mat_to_bv_poi.m```

## 3. Convert scalars to BV surface maps format:

1. run ```cifti2_dscalar_to_mat.py```
2. run ```cifti2_dscalar_mat_to_bv_smp.m```
