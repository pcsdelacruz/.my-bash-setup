# add user local bin to PATH (for claude CLI, etc.)
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

#My own preferred aliases
alias py3="python3"

# Kubernetes aliases
alias kgp="kubectl get pods"
alias kgs="kubectl get svc"
alias kgd="kubectl get deployments"
alias kgn="kubectl get nodes"
alias kga="kubectl get all"
alias kdp="kubectl describe pod"
alias kds="kubectl describe svc"
alias kdd="kubectl describe deployment"
alias kaf="kubectl apply -f"
alias kdel="kubectl delete"
alias kl="kubectl logs"
alias klf="kubectl logs -f"
alias kex="kubectl exec -it"
alias kctx="kubectl config current-context"
alias kns="kubectl config set-context --current --namespace"

# Starship prompt
eval "$(starship init bash)"
