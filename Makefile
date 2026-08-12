VERSION=$(shell cat version)
REPO=rodrigorootrjportifolio
PROJETO=sinatra-desafio-2026-entrevista
TAG=${REPO}/${PROJETO}:${VERSION}
DIR=$(shell pwd -P)
RELEASE=rodrigorootrjportifolio/sinatra-desafio-2026-entrevista-dev:b6c8bf40ede6046da73909d6294763e068ecaa1f
## Flask
build:
	@docker build -t ${TAG} .
run:
	@docker run -it -p 8400:4567 ${TAG}
shell:
	@docker run -it -p 8442:4567 --mount type=bind,source=${DIR}/src,target=/app  --entrypoint /bin/bash  ${TAG}
echo:
	@echo ${TAG}	
push:
	@docker push ${TAG}	
shell-release:
	@docker run -it -p 8442:4567 --entrypoint /bin/sh  ${RELEASE}
rmi:
	@docker rmi --force ${RELEASE}	