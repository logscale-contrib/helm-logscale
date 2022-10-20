# humio-instance-helm-chart

This helm chart creates an instance of the HumioCluster defined by the Humio-operator and 
conditionally creates Strimzi/Kakfa and S3Proxy instances (azure)

## Using

Update copies of the example/* files appropriate for your environment

* common.yaml
* one kafka*-*.yaml
* one humio*-*.yaml

Note these files are maintained to be modular examples however they can be combined into a single values file or seperated based on your operations needs
