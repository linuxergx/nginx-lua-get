# nginx-lua
```bash
脚本本身写的比较匆忙,有许多可以优化的地方,lua只看了一个星期,所以没有写成一个文件,用了lua调用shell的方式 lua本身也可以写function函数,因为个人习惯shell用的比较多
关于白名单 其实可以把数据存储到redis中来做校验,redis特有的数据结构查询速度一定是比遍历数组之类的快一点.
```

##token.lua 释义
```bash
-- 获取用户请求头中含有Authorization认证的token信息
local token = ngx.req.get_headers()["Authorization"]
-- 将token转化为字符串 否则传递参数会有问题
local change = tostring(token)
-- 本地组装cmd执行shell脚本 同时将转化好的token传递给shell
local cmd = ("sh base1.sh " .. change)
-- 使用io.popen的方式执行命令是可以获取到脚本返回值的 os.execute的方式只能获取到系统返回值
local t = io.popen(cmd)
local result = t:read("*all")
-- 读取返回值将返回值转换成为num格式 否则无法判断
local num = tonumber(result)
-- 将返回值进行判断 是否等与两百(返回值自己定义 对应http状态码)不等则返回403 
if num ~= 200 then
    -- 将403状态返回给ng代理页面    
    ngx.exit(ngx.HTTP_FORBIDDEN)
    -- if...end的结束格式    
end
-- 关闭io.popen的方式
t:close()
```

##bash1.sh
```bash
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

```

##name.txt
就是一个用户白名单
