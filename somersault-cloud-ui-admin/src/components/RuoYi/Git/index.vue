<template>
  <div>
    <svg-icon icon-class="github" @click="goto"/>
  </div>
</template>

<script>
export default {
  name: 'EntdiyCloudGit',
  data() {
    return {
      url: 'https://gitee.com/xautlx/somersault-cloud-ui'
    }
  },
  methods: {
    goto() {
      window.open(this.url)
    }
  }
}
</script>
