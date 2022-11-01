#!/bin/bash

# 終了処理
function shutdown() {
    kill -QUIT $(jobs -p)
    wait
    echo "exit $1"
    exit $1
}

# SIGQUIT 受信時は正常終了(終了ステータス 0)
trap "shutdown 0" SIGQUIT

# php-fpm を子プロセスとして起動 & listen 完了まで待機
php-fpm -F &
while [ ! -e /var/run/php-fpm.sock ]; do :; done

# nginx を子プロセスとして起動
nginx -g "daemon off;" &

# 子プロセスのいずれかが終了した場合は異常終了(終了ステータス 1)
wait -n
shutdown 1
