.PHONY: prune test, build run

FRONTEND_PATH = $(PWD)/frontend
BACKEND_PATH = $(PWD)/backend

fabric:
	fab update_ssm_parameters:stage=$(stage),project=backend,overwrite=$(overwrite)

# env:
# 	@if [ -d "$(BACKEND_PATH)" ]; then cd $(BACKEND_PATH) && $(echo DB_HOST); fi

test:
	@if [ -d "$(FRONTEND_PATH)" ]; then cd $(FRONTEND_PATH) && npm run test; fi
	@if [ -d "$(BACKEND_PATH)" ]; then cd $(BACKEND_PATH) && $(MAKE) test; fi

run:
	@if [ -d "$(FRONTEND_PATH)" ]; then cd $(FRONTEND_PATH) && npm run dev; fi
	@if [ -d "$(BACKEND_PATH)" ]; then cd $(BACKEND_PATH) && $(MAKE) run; fi

build:
# 	@if [ -d "$(FRONTEND_PATH)" ]; then cd $(FRONTEND_PATH) && npm run build; fi
	@if [ -d "$(BACKEND_PATH)" ]; then cd $(BACKEND_PATH) && $(MAKE) build; fi

prune:
	git checkout develop && git pull origin develop && git fetch -p && git branch --merged | egrep -v "(^\*|master|develop)" | xargs git branch -d

ecr-login:
	aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_REPOSITORY}
