# Arcane incantation to print all the other targets, from https://stackoverflow.com/a/26339924
help:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'


conda-clean-update:
	conda env remove --name fsdl-text-recognizer-2021
	conda clean --yes --all --force-pkgs-dirs
	make conda-update

# Install exact Python and CUDA versions
conda-update:
	conda env update --prune -f environment.yml
	echo "!!!RUN RIGHT NOW:\nconda activate fsdl-text-recognizer-2021"

# Compile and install exact pip packages
pip-tools:
	pip install pip-tools
#pip-compile requirements/channel_specific.in  --pip-args "no-cache-dir"
	pip-compile requirements/prod.in && pip-compile requirements/dev.in
	pip-sync requirements/prod.txt requirements/dev.txt

# Example training command
train-mnist-cnn-ddp:
	python lab9/training/run_experiment.py --max_epochs=10 --gpus=-1 --accelerator=ddp --num_workers=20 --data_class=MNIST --model_class=MLP

# Overfit on single batch
overfit:
	python lab9/training/run_experiment.py --max_epochs=10 --gpus=-1 --accelerator=ddp --num_workers=20 --data_class=MNIST --model_class=MLP  --overfit_batches=1

# Lint
lint:
	tasks/lint.sh
