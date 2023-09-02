<template>
  <div>
    <svg-icon icon-class="question" @click="goto"/>
  </div>
</template>

<script>
export default {
  name: 'SomersaultCloudDoc',
  data() {
    return {
      url: 'http://doc.entdiy.xyz:8800/'
    }
  },
  methods: {
    goto() {
      window.open(this.url)
    }
  }
}
</script>
