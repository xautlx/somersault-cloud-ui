import request from '@/utils/request'

// 获得MQTT服务列表
export function listSimpleMqttServers(query) {
  return request({
    url: '/iot/mqtt-server/list-simple',
    method: 'get',
    params: query
  })
}
