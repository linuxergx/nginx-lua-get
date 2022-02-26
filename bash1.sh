#!/bin/bash
# 将获取到的token追加到log.txt里 方便自己调试 可注释
echo -e $(date "+%Y-%m-%d %H:%M:%S") "\033[32m ==========> \033[0m" "获取到的加密token有效字段为:" $2 >>name.log
# 将token进行base64解码获取到json格式 从json中过滤preferred_username 并且返回 他的值
name=$(echo -n $2 | awk -F "." '{print $2}' | base64 -d 2>/dev/null | sed 's/,/\n/g' | grep "preferred_username" | sed 's/:/\n/g' | sed '1d' | sed 's/}//g' | sed 's/\"//g')
# 将解析到的名字追加到 name.log中也是为了方便调试
echo -e $(date "+%Y-%m-%d %H:%M:%S") "\033[32m ==========> \033[0m" "base64解码之后的用户名为:" $name >>name.log
# 进行嵌套判断 在首次登陆时token是空的 解析到的名字也是空 这时允许登录 并返回200
if [ -z "$2" ]; then
    echo 200
    # 当有token时 去精准匹配一个叫做name.txt用户库中的名字 有则返回200 没有就返回403
else
    if [[ $(grep -w "$name" name.txt | wc -l) == 1 ]]; then
        echo 200
    else
        echo 403
    fi
fi
