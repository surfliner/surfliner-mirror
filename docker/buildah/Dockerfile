# A simple image using buildah for creating/pushing container images
# see https://github.com/containers/buildah
FROM registry.fedoraproject.org/fedora-minimal:30

RUN microdnf -y update && microdnf -y clean all \
      && microdnf -y install buildah \
      && microdnf -y clean all
