# latex-lhs2tex-docker

An Ubuntu image with Texlive-full and Lhs2TeX preinstalled

## Usage

### Make

You can add this to your makefile:

```Makefile
.PHONY: env
env:
	docker run -it --rm -v ${PWD}:/home/docker/workdir agustinmista/latex-lhs2tex
```

And run `make env` to launch the build environment.

### GitHub Action CI

You can use this image to build LaTeX documents inside a GitHub action. The example below shows a simple workflow that assumes the existence of a `Makefile` and publishes all the generated PDFs as an artifact:

```yaml
name: Build and publish LaTeX documents

on: [push]

env:
  BUILD_ENV_IMAGE: agustinmista/latex-lhs2tex

jobs:
  build:
    runs-on: ubuntu-latest
    steps:

      - name: Set up Git repository
        uses: actions/checkout@v3
        with:
          path: repo

      - name: Fix file permissions in repo
        run: |
          chmod -R 777 repo
          sudo chown -R 1000:1000 repo

      - name: Pull custom Docker image
        run: docker pull ${{ env.BUILD_ENV_IMAGE }}

      - name: Compile LaTeX documents using custom Docker image
        run: |
          docker run \
            -v ${{ github.workspace }}/repo:/home/docker/workdir \
            ${{ env.BUILD_ENV_IMAGE }} \
            -c "make all"

      - name: Upload PDF file
        uses: actions/upload-artifact@v3
        with:
          name: artifact
          path: repo/*.pdf
```

**NOTE**: the GitHub's runner `UID:GID` are not the obvious `1000:1000`, so the files produced by the Docker image are not readable by it. The easiest way to solve this is to `chown`+`chmod` the repo files before accessing them outside of the container.

### Visual Studio Code DevContainer

You can instruct VSCode to open a project inside this container by adding the following to `.devcontainer/devcontainer.json`:

```json
{
  "image": "agustinmista/latex-lhs2tex",
  "customizations": {
    "vscode": {
      "extensions": [
        "mathematic.vscode-pdf",
        "Gruntfuggly.triggertaskonsave"
      ]
    }
  }
}
```

We can additionally instruct VSCode to build documents on save. For this we need two extra definitions in our project:

* `.vscode/settings.json`

```json
{
  "triggerTaskOnSave.tasks": {
    "make": [
      "*.lhs.tex",
      "notation.fmt",
      "references.bib",
			"some/other/folder/*.tex"
    ],
  },
  "triggerTaskOnSave.showNotifications": true,
  "triggerTaskOnSave.on": true,
  "triggerTaskOnSave.restart": true
}
```

* `.vscode/tasks.json`

```json
{
  // See https://go.microsoft.com/fwlink/?LinkId=733558
  // for the documentation about the tasks.json format
  "version": "2.0.0",
  "tasks": [
    {
      "label": "make",
      "type": "shell",
      "command": "make all",
      "problemMatcher": [],
      "group": {
        "kind": "build",
        "isDefault": true
      }
    }
  ]
}
```
