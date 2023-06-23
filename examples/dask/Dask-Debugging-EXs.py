#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import dask
import dask.bag as bag
import dask.dataframe as dd
from distributed.client import futures_of
import pandas
from io import StringIO
import numpy as np


# In[ ]:


# In[ ]:


urls = ["https://gender-pay-gap.service.gov.uk/viewing/download-data/2021",
        "https://www.pigscanfly.ca"]


# In[ ]:


# tag::handle[]
# Handling some potentially bad data, this assume line-by-line
raw_chunks = bag.read_text(
    urls,
    files_per_partition=1,
    linedelimiter="FAAAAAAAAAAAAAAAARTS")


def maybe_load_data(data):
    try:
        # Put your processing code here
        return (pandas.read_csv(StringIO(data)), None)
    except Exception as e:
        return (None, (e, data))


data = raw_chunks.map(maybe_load_data)
data.persist()
bad_data = data.filter(lambda x: x[0] is None)
good_data = data.filter(lambda x: x[1] is None)
# end::handle[]


# In[ ]:


dask.compute(bad_data)


# In[ ]:
