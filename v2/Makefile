# Copyright 2019 Brandon B. Jozsa/JinkIT and its Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

SHELL := /bin/bash
CHARTDIR := /opt/charts
PATH := ../bin:$(PATH)
HELM := helm
TASK := build
URL  ?= https://v1k0d3n.github.io/charts/

vpath $(HELM) $(CHARTDIR)/
vpath $(HELM) /usr/local/bin/
vpath $(HELM) ../bin/

EXCLUDES := kubernetes-common doc tests tools logs tmp $(wildcard v3-*)
CHARTS := kubernetes-common $(filter-out $(EXCLUDES), $(patsubst %/.,%,$(wildcard */.)))

.PHONY: $(EXCLUDES) $(CHARTS)

.IGNORE: repo

.SILENT: repo

all: repo $(CHARTS) clean-repo

repo:
	@echo ""
	@echo "Stage 1: Removing any potential index.yaml artifacts before beginning."
	@rm -rf ./index.yaml ||:
	@echo ""
	@echo "Stage 2: Removing any unnecessary repos from Helm before continuing."
	@$(HELM) repo remove stable ||:
	@$(HELM) repo remove local ||:
	@echo ""
	@echo "Stage 4: Clean - Killing any stale Helm servers that may be still running."
	@pkill $(HELM) ||:
	@echo ""
	@echo "Stage 5: Starting Helm server named local at: http://localhost:8879/charts"
	@$(HELM) serve --repo-path . --url $(URL) &
	@sleep 2
	@$(HELM) repo add local 'http://localhost:8879/charts'
	@echo ""
	@echo "Stage 6: Helm server should be ready at this time"

$(CHARTS):
	@echo
	@echo "===== Processing [$@] chart ====="
	@make $(TASK)-$@

init-%:
	if [ -f $*/Makefile ]; then make -C $*; fi
	if [ -f $*/requirements.yaml ]; then $(HELM) dep up $*; fi

lint-%: init-%
	if [ -d $* ]; then $(HELM) lint $*; fi

build-%: lint-%
	if [ -d $* ]; then $(HELM) package $*; fi

clean-repo:
	@echo ""
	@echo "Clean - Killing the repo at: http://localhost:8879/charts"
	@pkill $(HELM)

clean:
	@echo "Clean - Removed .b64, _partials.tpl, and _globals.tpl files"
	rm -f kubernetes-common/secrets/*.b64
	rm -f */templates/_partials.tpl
	rm -f */templates/_globals.tpl
	rm -f *tgz */charts/*tgz
	rm -f */requirements.lock
	-rm -rf */charts */tmpcharts
