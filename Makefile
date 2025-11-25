.PHONY: build-image dev-shell build-wheel test release

IMAGE=ghcr.io/<OWNER>/mlc-llm-dev:local

build-image:
	docker build -t $(IMAGE) -f docker/Dockerfile .

dev-shell: build-image
	docker run --rm -it -v $(PWD):/workspace -e DEV=1 $(IMAGE)

build-wheel: build-image
	docker run --rm -v $(PWD):/workspace $(IMAGE)

test:
	python -m pip install -r requirements-dev.txt || true
	pytest -q

# create a git tag and push
release:
	@echo "Create a new tag with: git tag vX.Y.Z && git push origin vX.Y.Z"