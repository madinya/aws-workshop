VENV_NAME = .venv
POETRY = $(VENV_NAME)/bin/poetry
PYTHON = $(VENV_NAME)/bin/python

.PHONY: venv install format lint test

venv:
	@echo "Creating virtual environment..."
	python3 -m venv $(VENV_NAME)

install: venv
	@echo "Installing Poetry..."
	$(PYTHON) -m pip install --upgrade pip
	$(PYTHON) -m pip install poetry

install-deps: venv
	@echo "Installing project dependencies using Poetry..."
	$(POETRY) install

format: venv
	@echo "Applying formatting..."
	$(POETRY) run black .

lint: venv
	@echo "Running linter..."
	$(POETRY) run flake8

test: venv
	@echo "Running tests..."
	$(POETRY) run pytest

all: install install-deps format lint test

clean:
	@echo "Cleaning up..."
	rm -rf $(VENV_NAME)
