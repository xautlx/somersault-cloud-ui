<template>
  <view class="container">
    <view class="auth-header">
      <view class="auth-logo">
        <u-avatar size="100" icon="github-circle-fill" fontSize="100"></u-avatar>
      </view>
    </view>

    <view class="auth-box">
      <view class="btn-group">
        <u-button type="primary" text="启动" @click="handleDeviceStart"></u-button>
      </view>
    </view>
  </view>
</template>

<script>

import { deviceStart } from '../../api/iot'

export default {
  data() {
    return {}
  },
  onLoad() {},
  onReady() {},
  methods: {
    handleDeviceStart() {
      deviceStart({ mobile: mobile, scene: 1 }).then(res => {
        //console.log(res)
        uni.hideLoading()
        uni.$u.toast('验证码已发送')
        // 通知验证码组件内部开始倒计时
        this.$refs.uCode.start()
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.container {
  height: calc(100vh - 70px);
  @include flex-space-between(column);
}

.auth-header {
  flex: 2;
  @include flex-center;
  .auth-logo {
    @include flex-center(column);
  }
}

.auth-box {
  @include flex-center(column);

  .btn-group {
    width: 600rpx;
    margin-bottom: 200rpx;
    .auth-btn {
      height: 90rpx;
      font-size: 32rpx;
    }
  }

  .reg-login-link {
    margin-top: 32rpx;
    text-align: center;
    color: #636363;
    font-size: 30rpx;
  }

  .auth-footer {
    font-size: 26rpx;
    color: #939393;
    .lk-text {
      color: $u-primary;
      text-decoration: $u-primary;
    }
  }
}
</style>
