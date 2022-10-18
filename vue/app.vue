<template>
  <div>
    <div>
      <a-form-model
        layout="inline"
        :model="form"
        :rules="rules"
        ref="form"
        :hideRequiredMark="true"
      >
        <a-form-model-item label="Host" prop="host">
          <a-input v-model="form.host" placeholder="Host" />
        </a-form-model-item>
        <a-form-model-item label="Subnet" prop="subnet">
          <a-input v-model="form.subnet" placeholder="Subnet" />
        </a-form-model-item>
        <a-form-model-item >
          <a-button :disabled="loading" type="primary" @click="scanNetwork">Scan</a-button>
        </a-form-model-item>
        <a-form-model-item>
          <a-alert v-if="error" type="error" :message="this.error" banner />
        </a-form-model-item>
      </a-form-model>
    </div>
    <a-table :columns="columns" :data-source="data.hosts" :row-key="row => row.ipNumber" :loading="loading">
    </a-table>
  </div>
</template>

<script>
export default {
  data () {
    return {
      data: [],
      loading: false,
      tries: 0,
      error: '',
      form: {
        host: '',
        subnet: ''
      },
      rules: {
        host: [
          {
            required: true,
            message: 'Please enter a host address',
            trigger: 'blur'
          },
          {
            type: 'string',
            pattern: /^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$/,
            message: 'Please enter a valid host address',
            trigger: 'blur'
          }
        ],
        subnet: [
          {
            required: true,
            message: 'Please enter a subnet'
          },
          {
            type: 'number',
            min: 0,
            max: 32,
            message: 'Please enter a valid subnet',
            transform: (value) => Number(value)
          }
        ]
      },
      columns: [
        {
          title: '#',
          dataIndex: 'number'
        },
        {
          title: 'Status',
          dataIndex: 'status'
        },
        {
          title: 'Host IP',
          dataIndex: 'ipNumber'
        },
        {
          title: 'MAC address',
          dataIndex: 'macAddr'
        },
        {
          title: 'Vendor',
          dataIndex: 'vendor'
        }
      ]
    }
  },
  methods: {
    scanNetwork () {
      this.$refs.form.validate((valid) => {
        if (!valid) return
        this.tries = 0
        this.error = ''
        this.$rpc
          .call('scan', 'scan', {
            network: `${this.form.host}/${this.form.subnet}`
          })
          .then((r) => {
            this.$timer.start('loadNetwork')
            this.loading = true
          })
      })
    },
    loadNetwork () {
      if (this.tries >= 60) {
        this.$timer.stop('loadNetwork')
        this.loading = false
        this.error = 'Scan timed out (60 sec)'
      }
      this.tries += 1
      this.$rpc.call('scan', 'get').then((r) => {
        if (!r.result) return
        if (r.result === 'failed') {
          this.$timer.stop('loadNetwork')
          this.loading = false
          this.error = 'Scan failed'
        }
        this.data = JSON.parse(r.result)
        this.data.hosts.forEach((r, i) => (r.number = i + 1))
        this.$timer.stop('loadNetwork')
        this.loading = false
      })
    },
    stopScan () {
      this.$timer.stop('loadNetwork')
      this.loading = false
    }
  },
  timers: {
    loadNetwork: { time: 1000, repeat: true }
  }
}
</script>
