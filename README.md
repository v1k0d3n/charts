# Helm Charts Repository

A collection of Helm charts for various projects and tools, served via GitHub Pages.

## Quick Start

```bash
# Add the repository
helm repo add v1k0d3n https://v1k0d3n.github.io/charts
helm repo update

# Search for available charts (including pre-release versions)
helm search repo v1k0d3n --devel

# Install kubevirt-redfish
helm install kubevirt-redfish v1k0d3n/kubevirt-redfish \
  --namespace kubevirt-redfish \
  --create-namespace
```

## Available Charts

| Chart | Description | Version |
|-------|-------------|---------|
| `kubevirt-redfish` | A Redfish-compatible API server for KubeVirt/OpenShift Virtualization | `0.0.0-0.2.0-f310b659` |

## Development

For information about contributing to this repository, see [Development Guide](docs/development/README.md).

## License

Apache License 2.0 - see [LICENSE](LICENSE) file for details.
