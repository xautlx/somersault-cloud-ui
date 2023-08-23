<template>
  <div>
    <svg-icon icon-class="question" @click="goto"/>
  </div>
</template>

<script>
export default {
  name: 'EntdiyCloudDoc',
  data() {
    return {
      url: 'http://124.71.2.242:8888/docs/'
    }
  },
  methods: {
    goto() {
      window.open(this.url)
    }
  }
}
</script>
