# RaBe http Image

[Apache HTTP Server](https://httpd.apache.org) container image based on [RaBe UBI9 Minimal](https://github.com/radiorabe/container-image-ubi9-minimal).

It uses some scripts from and is loosely based on the micro flavour of [sclorg/httpd-container](https://github.com/sclorg/httpd-container), the main difference being the upstream image used during the build and the selection of installed modules.

## Usage

If you want to host a static website, the following example could get you started.

```dockerfile
FROM ghcr.io/radiorabe/httpd:latest

COPY src/ /var/www/html
```

The server listens on ports 8080 and 8443 for both http and https.

## Release Management

The CI/CD setup uses semantic commit messages following the [conventional commits standard](https://www.conventionalcommits.org/en/v1.0.0/).
The workflow is based on the [RaBe shared actions](https://radiorabe.github.io/actions/)
and uses [go-semantic-commit](https://go-semantic-release.xyz/)
to create new releases.

The commit message should be structured as follows:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

The commit contains the following structural elements, to communicate intent to the consumers of your library:

1. **fix:** a commit of the type `fix` patches gets released with a PATCH version bump
1. **feat:** a commit of the type `feat` gets released as a MINOR version bump
1. **BREAKING CHANGE:** a commit that has a footer `BREAKING CHANGE:` gets released as a MAJOR version bump
1. types other than `fix:` and `feat:` are allowed and don't trigger a release

If a commit does not contain a conventional commit style message you can fix
it during the squash and merge operation on the PR.

## Build Process

The CI/CD setup uses [Docker build-push Action](https://github.com/docker/build-push-action)
 to publish container images. The workflow is based on the [RaBe shared actions](https://radiorabe.github.io/actions/).
