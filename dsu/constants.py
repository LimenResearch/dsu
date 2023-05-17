import os
import dsu

STATIC_FOLDER = os.path.join(os.path.dirname(os.path.dirname(dsu.__file__)), 
                             "static")
DATA_FOLDER = os.path.join(os.path.dirname(os.path.dirname(dsu.__file__)), 
                             "data")