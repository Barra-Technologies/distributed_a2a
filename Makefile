.PHONY: upload mypy test

test:
	PYTHONPATH=. pytest

bump-version:
	@if [ -z "$(VERSION)" ]; then \
		$(MAKE) bump-patch; \
	else \
		toml set project.version $(VERSION) --toml-path pyproject.toml; \
	fi

bump-major:
	@CURRENT_VERSION=$$(toml get project.version --toml-path pyproject.toml); \
	NEW_VERSION=$$(echo $$CURRENT_VERSION | awk -F. '{print $$1+1 ".0.0"}'); \
	echo "Bumping version from $$CURRENT_VERSION to $$NEW_VERSION"; \
	toml set project.version $$NEW_VERSION --toml-path pyproject.toml

bump-minor:
	@CURRENT_VERSION=$$(toml get project.version --toml-path pyproject.toml); \
	NEW_VERSION=$$(echo $$CURRENT_VERSION | awk -F. '{print $$1 "." $$2+1 ".0"}'); \
	echo "Bumping version from $$CURRENT_VERSION to $$NEW_VERSION"; \
	toml set project.version $$NEW_VERSION --toml-path pyproject.toml

bump-patch:
	@CURRENT_VERSION=$$(toml get project.version --toml-path pyproject.toml); \
	NEW_VERSION=$$(echo $$CURRENT_VERSION | awk -F. '{$$(NF) = $$(NF) + 1;} 1' OFS=.); \
	echo "Bumping version from $$CURRENT_VERSION to $$NEW_VERSION"; \
	toml set project.version $$NEW_VERSION --toml-path pyproject.toml

bump-rc:
	@CURRENT_VERSION=$$(toml get project.version --toml-path pyproject.toml); \
	if echo "$$CURRENT_VERSION" | grep -qE "rc[0-9]+$$"; then \
		BASE=$$(echo "$$CURRENT_VERSION" | sed -E 's/rc[0-9]+$$//'); \
		INDEX=$$(echo "$$CURRENT_VERSION" | sed -E 's/.*rc([0-9]+)$$/\1/'); \
		NEW_INDEX=$$((INDEX + 1)); \
		NEW_VERSION="$${BASE}rc$${NEW_INDEX}"; \
	elif echo "$$CURRENT_VERSION" | grep -q "rc$$"; then \
		BASE=$$(echo "$$CURRENT_VERSION" | sed -E 's/rc$$//'); \
		NEW_VERSION="$${BASE}rc1"; \
	else \
		NEW_VERSION=$$(echo $$CURRENT_VERSION | awk -F. '{$$(NF) = $$(NF) + 1;} 1' OFS=. | sed 's/$$/rc1/'); \
	fi; \
	echo "Bumping version from $$CURRENT_VERSION to $$NEW_VERSION"; \
	toml set project.version $$NEW_VERSION --toml-path pyproject.toml

upload:
	python -m build
	python3 -m twine upload dist/*

mypy:
	mypy .
