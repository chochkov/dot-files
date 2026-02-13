# nvm lazy loading
export NVM_DIR="$HOME/.nvm"

lazy_nvm_load() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}

nvm()  { lazy_nvm_load; nvm "$@" }
node() { lazy_nvm_load; node "$@" }
npm()  { lazy_nvm_load; npm "$@" }
npx()  { lazy_nvm_load; npx "$@" }
