# About

This image contains dropbear SSH daemon and gitolite with support for backups to S3-compatible object storage services like Wasabi.


# Usage

Clone the gitolite admin repository and add two lines on top of the configuration:

```
repo @all
  config mirrors.s3 = "amazon-s3://.wasabi@<BUCKET_NAME>/%GL_REPO"
```

You can add users and repositories, following the official guide: 
<https://github.com/sitaramc/gitolite#adding-users-and-repos>

## Kubernetes

Create the namespace

```
kubectl create -f manifests/01-Namespace.yaml
```

Add a registry pull secret

```
kubectl create secret -n gitolite docker-registry registry-pull-secret --docker-server=reg.this-is-fine.io --docker-username=generic --docker-password=$(pass show cluster/this-is-fine/registry/generic) --docker-email=git@this-is-fine.io

```

Create a secret for the S3 object storage backup

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: s3-secret-wasabi
  namespace: gitolite
type: Opaque
stringData:
  secret: |-
    accesskey: $(pass show web/wasabisys.com/api_access_key_git)
    secretkey: $(pass show web/wasabisys.com/api_secret_key_git)
    acl: private
    region: eu-central-1
    domain: s3.eu-central-1.wasabisys.com
EOF
```

Apply all other manifests

```
kubectl apply -f manifests/
```

Patch the `LoadBalancer` service to enable metallb's ip sharing

```
sharing_key=$(kubectl -n projectcontour get svc/envoy -o json | jq -r '.metadata.annotations["metallb.universe.tf/allow-shared-ip"]')
kubectl -n gitolite annotate --overwrite svc/gitolite metallb.universe.tf/allow-shared-ip=${sharing_key}
```
