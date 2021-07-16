#!/bin/zsh
echo $0

# https://subsplash.atlassian.net/wiki/spaces/SRE/pages/265880156/Configuring+Your+Workstation+to+Work+with+EKS
alias avsap='aws ' #'aws-vault exec sap -- '
alias avsaphm='avsap helm'
alias avsapkc='avsap kubectl'

alias hmsssandbox='avsaphm --kube-context=sap-sandbox'
alias hmssinfra='avsaphm --kube-context=sap-infra'
alias hmssdev='avsaphm --kube-context=sap-dev'
alias hmssstage='avsaphm --kube-context=sap-stage'
alias hmssprod='avsaphm --kube-context=sap-prod'

alias helm-sandbox='helm --kube-context=sap-sandbox'
alias helm-infra='helm --kube-context=sap-infra'
alias helm-dev='helm --kube-context=sap-dev'
alias helm-stage='helm --kube-context=sap-stage'
alias helm-prod='helm --kube-context=sap-prod'

alias kcsapsandbox='avsapkc --context=sap-sandbox'
alias kcsapinfra='avsapkc --context=sap-infra'
alias kcsapdev='avsapkc --context=sap-dev'
alias kcsapstage='avsapkc --context=sap-stage'
alias kcsapprod='avsapkc --context=sap-prod'

alias k6-sandbox='kubectl --context=sap-sandbox'
alias k6-infra='kubectl --context=sap-infra'
alias k6-dev='kubectl --context=sap-dev'
alias k6-stage='kubectl --context=sap-stage'
alias k6-prod='kubectl --context=sap-prod'

alias k9-sandbox='k9s --cluster sap-sandbox --context sap-sandbox'
alias k9-infra='k9s --cluster sap-infra --context sap-infra'
alias k9-dev='k9s --cluster sap-dev --context sap-dev'
alias k9-stage='k9s --cluster sap-stage --context sap-stage'
alias k9-prod='k9s --cluster sap-prod --context sap-prod'

alias k='kubectl' # 'awsexec kubectl'
alias kp='k get pods -n $n'
alias kx='kubectx'
alias kn='kubens'

# switch context
alias kx-dev='kubectx sap-dev'
alias kx-inf='kubectx sap-infra'
alias kx-sand='kubectx sap-sandbox'
alias kx-stage='kubectx sap-stage'
alias kx-prod='kubectx sap-prod'
