# release

Bash [script](/release) for automating releases. Uses [git-cliff](https://github.com/orhun/git-cliff) to get a version suggestion, updates the changelog, and creates a new version tag.

## ✨ Features

- Ensures releases are made from the default branch
- Verifies the working directory is clean
- Checks if the local repository is up-to-date
- Suggests a version number using git-cliff
- Updates the CHANGELOG.md file
- Creates a signed and annotated git tag
- Supports custom pre-release and post-release hooks

> [!IMPORTANT]
> This script performs a signed tag operation (`git tag -s`). Ensure you have a [GPG key set up](https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key) for signing.

## 📝 Usage

1. [Set up git-cliff](https://git-cliff.org/docs/).
2. Place the `release` script in your project's root directory.
3. Run the script:

```bash
bash release [version_tag]
```

If you don't provide a version tag, the script will suggest one based on git-cliff's output.

This script works best when you ensure your commit messages follow the [Conventional Commits](https://www.conventionalcommits.org) format. Check out my tool [git-sumi](https://github.com/welpo/git-sumi) to enforce this format on your projects.

## 🪝 Hooks

The script supports custom hooks for project-specific release tasks. Create executable files in a `.release-hooks` directory in your project root:

- `pre-release`: First thing that runs after verifying script is ready to go
- `post-release`: Runs after creating the release tag

Hooks receive the version tag (e.g., "v1.2.3") as their first argument. Example of a bash pre-release hook:

```bash
# .release-hooks/pre-release
#!/usr/bin/env bash

VERSION_TAG="$1"
poetry version "${VERSION_TAG#v}"  # Update version in pyproject.toml
```

Hooks can be in any language as long as they are executable (`chmod +x` required).

## 👥 Contributing

I'm making this repository public to simplify syncing changes to this script across my projects. If you decide to use the script and encounter any issues or have suggestions, feel free to submit issues or pull requests.

## 📄 License

The code is available under the [MIT license](./LICENSE).
