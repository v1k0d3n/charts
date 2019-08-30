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
INSP := inspect
TEMP := template

vpath $(HELM) $(CHARTDIR)/
vpath $(HELM) /usr/local/bin/
vpath $(HELM) ../bin/

EXCLUDES := kubernetes-common doc tests tools logs tmp
CHARTS := kubernetes-common $(filter-out $(EXCLUDES), $(patsubst %/.,%,$(wildcard */.)))

.PHONY: $(EXCLUDES) $(CHARTS)

.IGNORE: repo

.SILENT: repo

all: repo $(CHARTS)

repo:
	@echo "Removing any unnecessary repos from Helm before continuing."
	@$(HELM) repo remove stable ||:
	@$(HELM) repo remove local ||:
	@echo "Killing any stale Helm servers that may be still running."
	@pkill helm ||:
	@echo "Starting Helm server named local at: http://localhost:8879/charts"
	@$(HELM) serve &
	@sleep 2
	@$(HELM) repo add local 'http://localhost:8879/charts'
	@echo "Helm server should be ready at this time"

$(CHARTS):
	@echo
	@echo "===== Inspecting Chart - [$@] ====="
	@make $(INSP)-$@
	@echo
	@echo "===== Templating Chart - [$@] ====="
	@make $(TEMP)-$@
	@echo
	@echo "===== Packaging Chart - [$@]  ====="
	@make $(TASK)-$@

init-%:
	if [ -f $*/Makefile ]; then make -C $*; fi
	if [ -f $*/requirements.yaml ]; then $(HELM) dep up $*; fi

lint-%: init-%
	if [ -d $* ]; then $(HELM) lint $*; fi

build-%: lint-%
	if [ -d $* ]; then $(HELM) package $*; fi

inspect-%: lint-%
	if [ -d $* ]; then $(HELM) inspect $*; fi

template-%: lint-%
	if [ -d $* ]; then $(HELM) template $*; fi

clean:
	@echo "Removed .b64, _partials.tpl, and _globals.tpl files"
	rm -f kubernetes-common/secrets/*.b64
	rm -f */templates/_partials.tpl
	rm -f */templates/_globals.tpl
	rm -f *tgz */charts/*tgz
	rm -f */requirements.lock
	-rm -rf */charts */tmpcharts
