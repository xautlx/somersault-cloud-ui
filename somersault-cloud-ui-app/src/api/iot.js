//请求工具参考https://ext.dcloud.net.cn/plugin?id=392
const {http} = uni.$u

//启动设备
export const deviceStart = data => http.post('/iot/device/exec/' + data.cmd + '/' + data.id, data.body || {})
