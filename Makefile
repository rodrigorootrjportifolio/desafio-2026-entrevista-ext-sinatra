VERSION=$(shell cat version)
REPO=rodrigorootrjportifolio
PROJETO=sinatra-desafio-2026-entrevista
TAG=${REPO}/${PROJETO}:${VERSION}
DIR=$(shell pwd -P)
RELEASE=
## Flask
build:
	@docker build -t ${TAG} .
run:
	@docker run -it -p 8300:5000 ${TAG}
shell:
	@docker run -it -it -p 8342:5000 --mount type=bind,source=${DIR}/src,target=/app  --entrypoint /bin/sh  ${RELEASE}
echo:
	@echo ${TAG}	
push:
	@docker push ${TAG}	
shell-release:
	@docker run -it -it -p 8342:5000 --entrypoint /bin/sh  ${RELEASE}
rmi:
	@docker rmi --force ${RELEASE}	