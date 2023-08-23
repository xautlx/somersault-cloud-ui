<template>
  <div class="app-container">

    <!-- 搜索工作栏 -->
    <el-form :model="queryParams" ref="queryForm" size="small" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="设备编号" prop="uniCode">
        <el-input v-model="queryParams.uniCode" placeholder="请输入设备唯一编号" clearable @keyup.enter.native="handleQuery"/>
      </el-form-item>
      <el-form-item label="设备名称" prop="name">
        <el-input v-model="queryParams.name" placeholder="请输入设备名称" clearable @keyup.enter.native="handleQuery"/>
      </el-form-item>
      <el-form-item label="创建时间" prop="createTime">
        <el-date-picker v-model="queryParams.createTime" style="width: 240px" value-format="yyyy-MM-dd HH:mm:ss"
                        type="daterange"
                        range-separator="-" start-placeholder="开始日期" end-placeholder="结束日期"
                        :default-time="['00:00:00', '23:59:59']"/>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="el-icon-search" @click="handleQuery">搜索</el-button>
        <el-button icon="el-icon-refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- 操作工具栏 -->
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button-group>
          <el-button type="primary" plain icon="el-icon-connection" size="mini" :disabled="multiple"
                     @click="handleExecTest"
                     v-hasPermi="['iot:device-info:exec']">连接测试
          </el-button>
          <el-button type="primary" plain icon="el-icon-video-play" size="mini" :disabled="multiple"
                     @click="handleExecRun"
                     v-hasPermi="['iot:device-info:exec']">启动运行
          </el-button>
        </el-button-group>
      </el-col>
      <el-col :span="1.5">
        <el-dropdown @command="(command, item) => handleCommand(command, item)">
          <el-button type="primary" plain size="mini" icon="el-icon-d-arrow-right" :disabled="multiple">状态</el-button>
          <el-dropdown-menu slot="dropdown">
            <el-dropdown-item command="handleStatus" data-status="0" size="mini" type="text" icon="el-icon-open"
                              v-hasPermi="['iot:device-info:update']">开启
            </el-dropdown-item>
            <el-dropdown-item command="handleStatus" data-status="1" size="mini" type="text" icon="el-icon-turn-off"
                              v-hasPermi="['iot:device-info:update']">关闭
            </el-dropdown-item>
          </el-dropdown-menu>
        </el-dropdown>
      </el-col>
      <el-col :span="1.5">
        <el-button type="primary" plain icon="el-icon-plus" size="mini" @click="handleAdd"
                   v-hasPermi="['iot:device-info:create']">新增
        </el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="warning" plain icon="el-icon-download" size="mini" @click="handleExport"
                   :loading="exportLoading"
                   v-hasPermi="['iot:device-info:export']">导出
        </el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button type="danger" plain icon="el-icon-delete" size="mini" :disabled="multiple"
                   @click="handleDelete"
                   v-hasPermi="['iot:device-info:delete']">删除
        </el-button>
      </el-col>
      <right-toolbar :showSearch.sync="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <!-- 列表 -->
    <el-table ref="deviceInfoListTable" v-loading="loading" :data="list"
              @selection-change="handleSelectionChange"
              @sort-change="handleSortChange"
              @filter-change="handleFilterChange"
              @row-dblclick="handleUpdate">
      <el-table-column type="selection" width="50" align="center"/>
      <el-table-column label="设备编号" align="center" prop="uniCode" sortable/>
      <el-table-column label="设备名称" align="center" prop="name"/>
      <el-table-column label="MQTT配置" align="center" prop="mqttServer.type"
                       column-key="mqttServerId"
                       :filter-multiple="false"
                       :filters="mqttServerList.map(item => ({text: item.type, value: item.id}))"
      />
      <el-table-column label="状态" align="center" prop="status"
                       column-key="status"
                       :filter-multiple="false"
                       :filters="getDictDataFilters(DICT_TYPE.COMMON_STATUS)">
        <template v-slot="scope">
          <dict-tag :type="DICT_TYPE.COMMON_STATUS" :value="scope.row.status"/>
        </template>
      </el-table-column>
      <el-table-column label="创建时间" align="center" prop="createTime" width="180">
        <template v-slot="scope">
          <span>{{ parseTime(scope.row.createTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template v-slot="scope">
          <el-button size="mini" type="text" icon="el-icon-edit" @click="handleUpdate(scope.row)"
                     v-hasPermi="['iot:device-info:update']">修改
          </el-button>
          <el-dropdown @command="(command, item) =>  handleCommand(command, item, scope.row)">
            <el-button size="mini" type="text" icon="el-icon-d-arrow-right">更多</el-button>
            <el-dropdown-menu slot="dropdown">
              <el-dropdown-item command="handleExecTest" size="mini" type="text" icon="el-icon-connection"
                                v-hasPermi="['iot:device-info:exec']">连接测试
              </el-dropdown-item>
              <el-dropdown-item command="handleExecRun" size="mini" type="text" icon="el-icon-video-play"
                                v-hasPermi="['iot:device-info:exec']">启动运行
              </el-dropdown-item>
              <el-dropdown-item command="handleStatus" data-status="0" size="mini" type="text" icon="el-icon-open"
                                v-hasPermi="['iot:device-info:update']" divided>开启
              </el-dropdown-item>
              <el-dropdown-item command="handleStatus" data-status="1" size="mini" type="text" icon="el-icon-turn-off"
                                v-hasPermi="['iot:device-info:update']">关闭
              </el-dropdown-item>
              <el-dropdown-item command="handleDelete" size="mini" type="text" icon="el-icon-delete"
                                v-hasPermi="['iot:device-info:delete']" divided>删除
              </el-dropdown-item>
            </el-dropdown-menu>
          </el-dropdown>
        </template>
      </el-table-column>
    </el-table>
    <!-- 分页组件 -->
    <pagination v-show="total > 0" :total="total" :page.sync="queryParams.pageNo" :limit.sync="queryParams.pageSize"
                @pagination="getList"/>

    <!-- 对话框(添加 / 修改) -->
    <el-dialog :title="title" :visible.sync="open" width="700px" append-to-body>
      <el-form ref="form" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="设备编号" prop="uniCode">
          <el-input v-model="form.uniCode" placeholder="请输入设备唯一编号"/>
        </el-form-item>
        <el-form-item label="设备名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入设备名称"/>
        </el-form-item>
        <el-form-item label="连接Token" prop="connToken">
          <el-input v-model="form.connToken" placeholder="请输入连接Token"/>
        </el-form-item>
        <el-form-item label="MQTT配置" prop="mqttServerId">
          <el-select v-model="form.mqttServerId" placeholder="请选择">
            <el-option v-for="item in mqttServerList" :key="parseInt(item.id)" :label="item.label"
                       :value="parseInt(item.id)"/>
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio v-for="dict in getDictDatas(DICT_TYPE.COMMON_STATUS)" :key="parseInt(dict.value)"
                      :label="parseInt(dict.value)">
              {{ dict.label }}
            </el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import {DICT_TYPE, getDictDataLabel} from '@/utils/dict'
import {
  createDeviceInfo,
  updateDeviceInfo,
  deleteDeviceInfo,
  getDeviceInfo,
  getDeviceInfoPage,
  exportDeviceInfoExcel,
  execCommand, updateDeviceInfoStatus
} from "@/api/iot/deviceInfo";

import {listSimpleMqttServers} from "@/api/iot/mqttServer";

export default {
  name: "DeviceInfo",
  components: {},
  data() {
    return {
      // 遮罩层
      loading: true,
      // 导出遮罩层
      exportLoading: false,
      // 非多个禁用
      multiple: true,
      // 显示搜索条件
      showSearch: true,
      // 总条数
      total: 0,
      // 设备信息列表
      list: [],
      // 弹出层标题
      title: "",
      // 是否显示弹出层
      open: false,
      mqttServerList: [],
      // 查询参数
      queryParams: {
        pageNo: 1,
        pageSize: 10,
        uniCode: null,
        name: null,
        connToken: null,
        createTime: [],
        mqttServerId: null,
        status: null,
      },
      // 表单参数
      form: {},
      // 表单校验
      rules: {},
    };
  },
  created() {
    this.getList();
    this.getMqttServerList();
  },
  methods: {
    /** 查询MQTT服务下拉 */
    getMqttServerList() {
      listSimpleMqttServers().then(response => {
        this.mqttServerList = response.data;
      });
    },
    handleCommand2(key) {
      console.log(key)
    },
    /** 更多操作 */
    handleCommand(command, item, row) {
      console.log(row)
      eval("this." + command + "(item, row)");
    },
    /** 查询列表 */
    getList() {
      this.loading = true;
      // 执行查询
      getDeviceInfoPage(this.queryParams).then(response => {
        this.list = response.data.list;
        this.total = response.data.total;
        this.loading = false;
      });
    },
    /** 取消按钮 */
    cancel() {
      this.open = false;
      this.reset();
    },
    /** 表单重置 */
    reset() {
      this.form = {
        id: undefined,
        uniCode: undefined,
        name: undefined,
        connToken: undefined,
        mqttServerId: undefined,
        status: undefined,
      };
      this.resetForm("form");
    },
    /** 搜索按钮操作 */
    handleQuery() {
      this.queryParams.pageNo = 1;
      this.getList();
    },
    /** 重置按钮操作 */
    resetQuery() {
      this.resetForm("queryForm");
      this.handleQuery();
    },
    /** 新增按钮操作 */
    handleAdd() {
      this.reset();
      this.open = true;
      this.title = "添加设备信息";
    },
    /** 修改按钮操作 */
    handleUpdate(row) {
      this.reset();
      const id = row.id;
      getDeviceInfo(id).then(response => {
        this.form = response.data;
        this.open = true;
        this.title = "修改设备信息";
      });
    },
    /** 提交按钮 */
    submitForm() {
      this.$refs["form"].validate(valid => {
        if (!valid) {
          return;
        }
        // 修改的提交
        if (this.form.id != null) {
          updateDeviceInfo(this.form).then(response => {
            this.$modal.msgSuccess("修改成功");
            this.open = false;
            this.getList();
          });
          return;
        }
        // 添加的提交
        createDeviceInfo(this.form).then(response => {
          this.$modal.msgSuccess("新增成功");
          this.open = false;
          this.getList();
        });
      });
    },
    /** 删除按钮操作 */
    handleDelete(row) {
      const ids = (row && row.id) ? [row.id] : this.ids;
      this.$modal.confirm('是否确认删除所选 ' + ids.length + ' 条数据?').then(function () {
        return deleteDeviceInfo(ids);
      }).then(() => {
        this.getList();
        this.$modal.msgSuccess("删除成功");
      }).catch(() => {
      });
    },
    /** 导出按钮操作 */
    handleExport() {
      // 处理查询参数
      let params = {...this.queryParams};
      params.pageNo = undefined;
      params.pageSize = undefined;
      this.$modal.confirm('是否确认导出所有设备信息数据项?').then(() => {
        this.exportLoading = true;
        return exportDeviceInfoExcel(params);
      }).then(response => {
        this.$download.excel(response, '设备信息.xls');
        this.exportLoading = false;
      }).catch(() => {
      });
    },
    /** 多选框选中数据 */
    handleSelectionChange(selection) {
      this.ids = selection.map(item => item.id)
      this.multiple = !selection.length
    },
    /** 排序触发事件 */
    handleSortChange(column) {
      if (column.order === "ascending") {
        this.queryParams.sortOrder = column.prop
      } else if (column.order === "descending") {
        this.queryParams.sortOrder = "-" + column.prop
      } else {
        this.queryParams.sortOrder = ""
      }
      this.getList();
    },
    /** 筛选变更事件 */
    handleFilterChange(filters) {
      this.$refs.deviceInfoListTable.columns.forEach(column => {
        if (column.filters && column.columnKey) {
          if (filters[column.columnKey] && filters[column.columnKey].length > 0) {
            this.queryParams[column.columnKey] = filters[column.columnKey][0];
          } else {
            this.queryParams[column.columnKey] = undefined;
            this.$refs.deviceInfoListTable.clearFilter(column.columnKey);
          }
        }
      })
      this.getList();
    },
    /** 执行设备连接测试指令: test */
    handleExecTest(item, row) {
      const ids = (row && row.id) ? [row.id] : this.ids;
      execCommand('test', ids);
      this.$modal.msgSuccess("测试指令已发送");
    },
    /** 执行设备启动运行指令: run */
    handleExecRun(item, row) {
      const ids = (row && row.id) ? [row.id] : this.ids;
      this.$modal.confirm('是否确认启动运行所选 ' + ids.length + ' 个设备?').then(function () {
        return execCommand('run', ids);
      }).then(() => {
        this.$modal.msgSuccess("启动运行指令已发送");
      }).catch(() => {
      });
    },
    /** 处理状态操作 */
    handleStatus(item, row) {
      const ids = (row && row.id) ? [row.id] : this.ids;
      const status = parseInt(item.$attrs['data-status'])
      this.$modal.confirm('是否确认对所选 ' + ids.length + ' 条数据设置状态：' + getDictDataLabel(DICT_TYPE.COMMON_STATUS, status) + '?').then(function () {
        return updateDeviceInfoStatus(status, ids);
      }).then(() => {
        this.$modal.msgSuccess("状态更新成功");
        this.getList();
      }).catch(() => {
      });
    }
  }
};
</script>
