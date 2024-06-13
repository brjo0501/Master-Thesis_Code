from coppeliasim_zmqremoteapi_client import RemoteAPIClient
import pandas as pd
import numpy as np

import networkx as nx
import matplotlib.pyplot as plt

import lingam
from lingam.utils import make_dot

x3 = np.random.uniform(size=10000)
x0 = 3.0*x3 + np.random.uniform(size=10000)
x2 = 6.0*x3 + np.random.uniform(size=10000)
x1 = 3.0*x0 + 2.0*x2 + np.random.uniform(size=10000)
x5 = 4.0*x0 + np.random.uniform(size=10000)
x4 = 8.0*x0 - 1.0*x2 + np.random.uniform(size=10000)
X = pd.DataFrame(np.array([x0, x1, x2, x3, x4, x5]).T ,columns=['x0', 'x1', 'x2', 'x3', 'x4', 'x5'])

model = lingam.DirectLiNGAM()
model.fit(X)
dot = make_dot(model.adjacency_matrix_, labels=['x0', 'x1', 'x2', 'x3', 'x4', 'x5'])
dot.format = 'png'
dot.render('lingam_graph')