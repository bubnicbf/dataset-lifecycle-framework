import pytest
from kubetest import client
import os

test = os.getenv("NAMESPACE")

@pytest.mark.namespace(create=False, name=test)
def test_one(kube: client.TestClient):
    minio_deployment = kube.get_deployments(labels={"app":"minio"})["minio"]
    minio_deployment.wait_until_ready(3*60)
    pass