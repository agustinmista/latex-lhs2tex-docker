# latex-lhs2tex-docker

An Ubuntu image with Texlive-full and Lhs2TeX preinstalled

## Usage

Add this to your makefile:

```Makefile
.PHONY: env
env:
	docker run -it --rm -v ${PWD}:/home/docker/workdir agustinmista/latex-lhs2tex
```

And run `make env` to launch the build environment.
