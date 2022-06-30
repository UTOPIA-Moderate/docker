#!/bin/bash
#健康检查脚本,看8081端口返回是否正常
http_code=$(curl -I -o /dev/null -S -w %{http_code} http://127.0.0.1:8081/)

if test $http_code -eq "200"
then
    echo "0"
else
    echo "1"
fi