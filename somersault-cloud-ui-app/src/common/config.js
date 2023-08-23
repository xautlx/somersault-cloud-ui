module.exports = {
  //后端接口地址
  baseUrl: '/app-api',
  // baseUrl: 'http://api-dashboard.somersault-cloud.entdiy.xyz/app-api',
  // 超时
  timeout: 30000,
  // 禁用 Cookie 等信息
  withCredentials: false,
  header: {
    //租户ID
    'tenant-id': 1
  }
}
