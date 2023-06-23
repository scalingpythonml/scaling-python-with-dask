#!/usr/bin/env python
# coding: utf-8

# In[ ]:


# Dask local GPU


# In[ ]:


from dask_kubernetes import KubeCluster, make_pod_spec
from dask.distributed import Client
import dask
get_ipython().system('pip freeze')


# In[ ]:


# Dask Kube GPU
# tag::worker_template_with_gpu[]
worker_template = make_pod_spec(image='holdenk/dask:latest',
                                memory_limit='8G', memory_request='8G',
                                cpu_limit=1, cpu_request=1)
worker_template.spec.containers[0].resources.limits["gpu"] = 1
worker_template.spec.containers[0].resources.requests["gpu"] = 1
worker_template.spec.containers[0].args[0] = "dask-cuda-worker --resources 'GPU=1'"
worker_template.spec.containers[0].env.append("NVIDIA_VISIBLE_DEVICES=ALL")
# Or append --resources "GPU=2"
# end::worker_template_with_gpu[]
# tag::worker_template_with_label[]
worker_template = make_pod_spec(image='holdenk/dask:latest',
                                memory_limit='8G', memory_request='8G',
                                cpu_limit=1, cpu_request=1)
worker_template.spec.node_selector = "node.kubernetes.io/gpu=gpu"
worker_template.spec.containers[0].args[0] = "dask-cuda-worker --resources 'GPU=1'"
worker_template.spec.containers[0].env.append("NVIDIA_VISIBLE_DEVICES=ALL")
worker_template.spec.
# Or append --resources "GPU=2"
# end::worker_template_with_label[]
scheduler_template = make_pod_spec(image='holdenk/dask:latest',
                                   memory_limit='4G', memory_request='4G',
                                   cpu_limit=1, cpu_request=1)
cluster = KubeCluster(
    pod_template=worker_template,
    scheduler_pod_template=scheduler_template,
    namespace="dask")
cluster.adapt()    # or create and destroy workers dynamically based on workload
client = Client(cluster)


# In[ ]:


#!pip install --user git+https://github.com/dask/dask-kubernetes.git


# In[ ]:


worker_template.spec.containers[0].env.append("NVIDIA_VISIBLE_DEVICES=ALL")


# In[ ]:


# tag::request_gpus[]
future = client.submit(how_many_gpus, 1, resources={'GPU': 1})
# end::request_gpus[]


# In[ ]:


with dask.annotate(resources={'GPU': 1}):
    y = x.map_partitions(func1)
