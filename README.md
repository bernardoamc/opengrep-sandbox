# opengrep-sandbox

Dockerfile and other utilities to easily test [opengrep](https://github.com/opengrep/opengrep).

### Dockerfile

Generates a container with the latest opengrep version and copies relative `files` and `rules` directories into it.

- No access to the network by default
- Running as `opengrepuser` instead of `root`

Manually building an running the container:

```bash
docker build -t opengrep-bash .
```

and

```bash
docker run --network none --rm -it opengrep-bash
```

We can also mount directories instead of copying relative directories into it:

```bash
docker run --network none --rm -it \
    -v /rules/path/on/host:/home/opengrepuser/rules \
    -v /files/path/on/host:/home/opengrepuser/files \
    opengrep-bash
```

### Running opengrep

Inside the container:

```bash
opengrep scan --quiet --metrics=off --json --time --disable-version-check --no-rewrite-rule-ids --disable-nosem --config ./rules files/
```

### setup.sh

Ideal if you already have an existing directory holding your rules and backed by git. Through it you can copy rules and modified files,
build the container and run it.

```bash
./setup <directory_with_branch> <rules_dir>
```

### copy_rules.sh

This script copies a target rules directory into a local `rules` one. It deletes any existing `rules` directory prior to it.

### git_copy.sh

Copies added or modified files from a git branch located in the `<target_directory>` into a `files` folder relative to this script.
