"""Gifti surface to BrainVoyager SRF format conversion step 1."""

import os
import numpy as np
from nibabel import load
from scipy.io import savemat

fname_gifti = '/media/Data_Drive/ISILON/600_ATLASES/vanessen/test/Q1-Q6_RelatedParcellation210.L.midthickness_MSMAll_2_d41_WRN_DeDrift.32k_fs_LR.surf.gii'
gii = load(fname_gifti)
basename = os.path.basename(fname_gifti).split('.')[0:-2]
basename = '.'.join(basename)
dirname = os.path.dirname(fname_gifti)


def compute_vertex_normals(verts, faces):
    """"Compute vertex normals.

    Parameters
    ----------
    verts: 2d numpy array, shape [nvertices, 3]
    Coordinates of vertices
    faces: 2d numpy array [nfaces, 3]
    Vertex indices forming triangles.

    Returns
    -------
    normals: 2d numpy array, shape [nvertices, 3]
    Unit vector vertex normals.

    """
    def normalize_v3(arr):
        """Normalize a numpy array of 3 component vectors shape=(n, 3)."""
        lens = np.sqrt(arr[:, 0]**2. + arr[:, 1]**2. + arr[:, 2]**2.)
        arr[:, 0] /= lens
        arr[:, 1] /= lens
        arr[:, 2] /= lens
        return arr

    norm = np.zeros(verts.shape, dtype=verts.dtype)
    # Create an indexed view into the vertex array
    tris = verts[faces]
    # Calculate the normals (cross product of the vectors v1-v0 & v2-v0)
    n = np.cross(tris[::, 1] - tris[::, 0], tris[::, 2] - tris[::, 0])
    # Normalize weights in each normal equally.
    n = normalize_v3(n)
    # Convert face normals to vertex normals and normalize again
    norm[faces[:, 0]] += n
    norm[faces[:, 1]] += n
    norm[faces[:, 2]] += n
    return normalize_v3(norm)


# extract vertices and faces
verts = gii.darrays[0].data
faces = gii.darrays[1].data
faces = faces[:, [0, 2, 1]]  # change winding (BV normals point inward)
norm = compute_vertex_normals(verts, faces)

# Save
mat = dict()
mat['vertices'] = verts
mat['faces'] = faces + 1  # to comply with matlab indexing
mat['normals'] = norm
fname_out = os.path.join(dirname, basename+'.mat')
savemat(fname_out, mat)
