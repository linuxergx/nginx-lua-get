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
