function _sf:start() {
  docker compose up -d
  docker compose kill nginx php
  symfony serve -d
}

function _sf:stop() {
  docker compose kill
  symfony serve:stop
}

function _sf:cc() {
  find var/cache/{test,dev,prod} -mindepth 1 -maxdepth 1 ! -name "profiler" -exec rm -rf {} \; 2>/dev/null
}

function _sf:cc:wa() {
  _sf:cc
  symfony console cache:warmup
  curl 'https://127.0.0.1:8000/api/v2' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' >/dev/null 2>&1 && echo 'API is up' || echo 'API is down'
}

function _sf:fixtures() {
  symfony console sylius:fixtures:load dev_protecthoms -n
}

function _sf:create_database() {
  _sf:cc
  symfony console doctrine:database:drop --force
  symfony console doctrine:database:create -n
  symfony console doctrine:migrations:migrate -n
  symfony console sylius:fixtures:load dev_protecthoms -n
}

function _sf:ram:start() {
  local env=${1:-dev}
  echo "Starting RAM cache for ${env}"
  mkdir -p /run/user/$(id -u)/sf-ram-${env}
  ln -sfn /run/user/$(id -u)/sf-ram-${env} var/cache/${env}
}

function _sf:ram:stop() {
  local env=${1:-dev}
  echo "Stopping RAM cache for ${env}"
  rm -rf /run/user/$(id -u)/sf-ram-${env}
  rm -rf var/cache/${env}
}

function _sf:test() {
  symfony php vendor/bin/phpunit $@
}
