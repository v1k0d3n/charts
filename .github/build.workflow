name: "Create cluster using KinD"
on: [pull_request, push]

jobs:
  kind:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - uses: v1k0d3n/setup-kind@v0.1.0
      with:
        version: "v0.5.0"        
    - name: KinD Information
      run: |
        export KUBECONFIG="$(kind get kubeconfig-path)"
        kubectl cluster-info
        kubectl get pods -n kube-system
    - name: Docker Information
      run: |
        docker ps -a
        docker images
    - name: Helm Fetch
      env:
        version_helm: v2.14.3
        distro_type: linux
        distro_arch: amd64
      run: |
        curl -o /tmp/${version_helm}-${distro_type}-${distro_arch}.tar.gz https://get.helm.sh/helm-${version_helm}-${distro_type}-${distro_arch}.tar.gz
        tar -zxvf /tmp/${version_helm}-${distro_type}-${distro_arch}.tar.gz -C /tmp/
        sudo mv /tmp/${distro_type}-${distro_arch}/helm /usr/local/bin/
        sudo mv /tmp/${distro_type}-${distro_arch}/tiller /usr/local/bin/
        rm -rf /tmp/${version_helm}-${distro_type}-${distro_arch}.tar.gz
        rm -rf /tmp/${distro_type}-${distro_arch}
        helm version --client --short
    - name: Helm Initialize
      run: |
        helm init
    - name: Helm Build Charts
      run: |
        make
