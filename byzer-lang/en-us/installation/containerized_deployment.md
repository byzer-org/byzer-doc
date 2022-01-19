# Containerized Deployment Operation Guide

Byzer provides various deployment methods for users to flexibly build and use in different scenarios (click to view the details of several deployment methods):

- [Sandbox independent deployment](/byzer-lang/en-us/installation/containerized_deployment/sandbox-standalone.md): The Sandbox image uniformly packages Byzer-lang, Byzer-notebook and mysql into one image, which is used to quickly experience Byzer locally. If you need to deploy multiple components separately, you can use the `Sandbox multi-container deployment`method.

- [Multi-container deployment](/byzer-lang/en-us/installation/containerized_deployment/muti-continer.md): The multi-container deployment method will arrange and deploy the three images of Byzer-lang, Byzer-notebook and mysql in a unified manner through docker-compose, which supports features such as health check and life cycle management.

- [K8S deployment](/byzer-lang/en-us/installation/containerized_deployment/K8S-deployment.md): Sandbox K8S provides a CLI to deploy the MLSQL engine on K8S.
