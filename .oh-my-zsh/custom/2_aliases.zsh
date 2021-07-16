#!/bin/zsh
echo $0

# shell aliases
#alias ...='cd ../..'

#alias ls='ls -GwF'

alias ll='ls -l'
alias lh='ls -lh'

alias ping='ping -c 3'
alias mkdir='mkdir -p'
alias clip='pbcopy'

alias go-src='cd ~/go/src'

# alias date='date +%y%m%d'
alias datetime='date +%y%m%d-%H:%M:%S'

# redefine find to exclude hidden dirs by default
alias find='f(){ find "$@" -not -path "*/\.*";  unset -f f; }; f'

#alias aws='aws2'       # prefer aws cli v2 over v1
#alias python='python3' # Prefer Python3 over Python (v2)
#alias pip='pip3'       # Prefer Python3 pip

alias setdns='networksetup -setdnsservers Wi-Fi 1.1.1.1'
alias cleardns='networksetup -setdnsservers Wi-Fi empty'

# various aliases borrowed from Ben
alias myip='ipconfig getifaddr en0'
alias ipconfig='ipconfig getifaddr en0'

alias login-bastion='ssh -A bryan@bastion.subsplash.net'
alias login-tableau='ssh -A ubuntu@ip-172-20-88-78.us-west-2.compute.internal'
alias login-snappages='ssh 54.201.70.208'
alias login-splunk='ssh -A ubuntu@ip-172-20-88-33.us-west-2.compute.internal'

# git aliases
alias gs='git status'
alias gdm='git branch --merged | egrep -v "(^\*|master|dev)" | xargs git branch -d'
alias gpoh='git push origin HEAD'
alias gpfwl='git push --force-with-lease'
alias gcompdm='git checkout master && git pull && git branch --merged | egrep -v "(^\*|master|dev)" | xargs git branch -d'
alias gdh='git diff head'
alias gdh1='git diff head~1'
alias gdh2='git diff head~2'
alias gcom='git checkout master'
alias gcod='git checkout dev'
alias gp='git pull'
alias grhh='git reset --hard HEAD'
alias gds='git diff --staged'
alias gspu='git stash push'
alias gspo='git stash pop'
alias grh='git reset HEAD'
alias grho='git reset --hard origin'
alias grbm='git rebase origin/master'
alias grbc='git rebase --continue'
alias grbs='git rebase --skip'
alias grpo='git remote prune origin'

# aliases for building/testing in go
alias go-test-integ='go test ./integ/ -tags=integ -count=1'
alias go-test-integ-verbose='go test -v ./integ/ -tags=integ -count=1'
alias go-test-integ-debug='go test -v ./integ/ -tags=integ -count=1 -debug'
alias go-run-local='export SERVICE=$(basename $(pwd)); go install ./... && $GOBIN/$SERVICE ./config/$SERVICE.local.json'
alias go-run-dev='go install ./... && SERVICE=$(basename $(pwd)) && $GOBIN/$SERVICE ./config/$SERVICE.dev.json'
alias go-run-stage='go install ./... && SERVICE=$(basename $(pwd)) && $GOBIN/$SERVICE ./config/$SERVICE.stage.json'
alias go-run-prod='go install ./... && SERVICE=$(basename $(pwd)) && $GOBIN/$SERVICE ./config/$SERVICE.prod.json'
alias goi='go install ./...'
alias govet='go vet ./...'
alias goit='go install ./... && go test ./... | grep -v "\[no test files\]"'
alias goclean='go clean ./...'
alias goct='go clean -testcache'
alias gobuild='go build ./...'
alias gobld='go build ./...'
alias gob='go build ./...'
alias gobl='GOOS=linux GOARCH=amd64 go build ./cmd/$(basename $(pwd))'
alias gotest='go test ./... | grep -v "\[no test files\]"'
alias gotst='go test ./... | grep -v "\[no test files\]"'
alias got='go test ./... | grep -v "\[no test files\]"'

# gitlab-cli: https://www.npmjs.com/package/git-lab-cli
alias mr='gitlab-cli merge-request --labels please-review,assign-sre --remove_source_branch --squash --target $(git rev-parse --abbrev-ref --symbolic-full-name @{u})'
alias mra='gitlab-cli merge-request --labels please-review --remove_source_branch --squash --target $(git rev-parse --abbrev-ref --symbolic-full-name @{u}) --assignee '
alias mrwip='gitlab-cli merge-request --message "WIP" --remove_source_branch --squash --target $(git rev-parse --abbrev-ref --symbolic-full-name @{u})'

# docker
alias docker-clean='docker ps -aq --filter status=dead --filter status=exited | xargs docker rm -v'

# docker-compose
alias dcd='docker-compose down -v'
alias dcp='docker-compose pull'
alias dcb='docker-compose build --pull'
alias dcbnc='docker-compose build --pull --no-cache'
alias dcu='docker-compose up'
alias dcbu='docker-compose build && docker-compose up'
alias dcdu='docker-compose down && docker-compose up'
alias dcdbu='docker-compose down && docker-compose build && docker-compose up'

# ECR
alias ecr-docker-login='aws ecr get-login-password --region $AWS_REGION | docker login $ECR_URL --username AWS --password-stdin'

# mongodb
alias mongo-dev='mongo --host mongodb-dev-00.awsusw2.subsplash.net -u bryan --authenticationDatabase admin -p'
alias mongo-stage='mongo --host mongodb-stage-00.awsusw2.subsplash.net -u bryan --authenticationDatabase admin -p'
alias mongo-prod='mongo --host mongodb-analytics-00.awsusw2.subsplash.net -u analytics --authenticationDatabase admin -p'

# kubernetes
# See ./kube-aliases.sh
