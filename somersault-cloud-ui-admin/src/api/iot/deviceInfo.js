import request from '@/utils/request'

// 创建设备信息
export function createDeviceInfo(data) {
  return request({
    url: '/iot/device-info/create',
    method: 'post',
    data: data
  })
}

// 更新设备信息
export function updateDeviceInfo(data) {
  return request({
    url: '/iot/device-info/update',
    method: 'put',
    data: data
  })
}

// 删除设备信息
export function deleteDeviceInfo(ids) {
  return request({
    url: '/iot/device-info/delete?' + ids.map((value) => "id=" + value).join("&"),
    method: 'delete'
  })
}

// 获得设备信息
export function getDeviceInfo(id) {
  return request({
    url: '/iot/device-info/get?id=' + id,
    method: 'get'
  })
}

// 获得设备信息分页
export function getDeviceInfoPage(query) {
  return request({
    url: '/iot/device-info/page',
    method: 'get',
    params: query
  })
}

// 导出设备信息 Excel
export function exportDeviceInfoExcel(query) {
  return request({
    url: '/iot/device-info/export-excel',
    method: 'get',
    params: query,
    responseType: 'blob'
  })
}

// 执行设备指令
export function execCommand(cmd, ids, data) {
  return request({
    url: '/iot/device-info/exec/' + cmd + '?' + ids.map((value) => "id=" + value).join("&"),
    method: 'post',
    data: data
  })
}

// 批量更新设备状态
export function updateDeviceInfoStatus(status, ids) {
  return request({
    url: '/iot/device-info/update-status/' + status + '?' + ids.map((value) => "id=" + value).join("&"),
    method: 'put'
  })
}
