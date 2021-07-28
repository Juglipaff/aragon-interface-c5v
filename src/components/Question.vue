<template>
    <div class="question">
      <div class="title"><span class="id">#{{this.question.id}}: </span>
        <span v-if="isText">{{questionTitle}}</span>
        <iframe class='pdf' v-else-if="question.script === '0x00000006'" title="iframe" :src="`https://docs.google.com/gview?embedded=true&url=${question.metadata}&amp;embedded=true`"/>
      </div>

      <div class="progress">
        Yes: {{question.yea}} <span v-if="!question.executed&&!expired" class="buttons">
        <button class="yes" v-if="hasPermission && canVote" v-on:click="vote(true)" :disabled="votedYes || !currentAccount || loading || !isRightChain"><span v-if="!loading">Vote</span><div v-else class="lds-ellipsis"><div></div><div></div><div></div><div></div></div></button>
      </span><br>
        <progress-bar
          :options="yesOptions"
          :value="yesValue"
        />
      </div>
      <div class="progress">
        No: {{question.nay}} <span v-if="!question.executed&&!expired" class="buttons">
        <button class="no" v-if="hasPermission && canVote" v-on:click="vote(false)" :disabled="votedNo || !currentAccount || loading || !isRightChain"><span v-if="!loading">Vote</span><div v-else class="lds-ellipsis"><div></div><div></div><div></div><div></div></div></button>
      </span><br>
        <progress-bar
          :options="noOptions"
          :value="noValue"
        />
      </div>
     <div class="execution">
       <span v-if="question.executed" class="passed">'&#10003; Passed</span>
       <span v-else-if="expired" :class="[ isPassedOrRejected==='\u2713 Passed' ? 'passed' : 'rejected']">{{isPassedOrRejected}}</span>
       <span v-else>{{time}}</span>
      </div>
    </div>
</template>

<script>
import { ethers } from 'ethers'
export default {
  name: 'Question',
  props: {
    votingContract: Object,
    question: Object,
    currentAccount: String,
    provider: Object,
    hasPermission: Boolean,
    updateList: Boolean,
    isRightChain: Boolean
  },
  data () {
    return {
      isText: true,
      time: '',
      questionTitle: '',
      canVote: false,
      loading: false,
      expired: false,
      startingExpireValue: true,
      intervalId: null,
      votedYes: false,
      votedNo: false,
      yesValue: 0,
      noValue: 0,
      yesOptions: {
        text: {
          hideText: true
        },
        progress: {
          color: '#2cc68f',
          backgroundColor: '#eeeeee',
          inverted: false
        },
        layout: {
          height: 6,
          width: 230,
          verticalTextAlign: 61,
          horizontalTextAlign: 43,
          zeroOffset: 0,
          strokeWidth: 30,
          progressPadding: 0,
          type: 'line'
        }
      },
      noOptions: {
        text: {
          hideText: true
        },
        progress: {
          color: '#FF6969',
          backgroundColor: '#eeeeee',
          inverted: false
        },
        layout: {
          height: 6,
          width: 230,
          verticalTextAlign: 61,
          horizontalTextAlign: 43,
          zeroOffset: 0,
          strokeWidth: 30,
          progressPadding: 0,
          type: 'line'
        }
      }
    }
  },
  watch: {
    currentAccount: function () {
      this.loading = false
    },
    updateList: function () {
      if (!this.expired && !this.question.executed) {
        this.getBarValues()
        if (this.currentAccount) {
          this.votingContract.getVoterState(this.question.id, this.currentAccount)
            .then(res => {
              if (res === 0) {
                this.votedNo = false
                this.votedYes = false
              } else if (res === 1) {
                this.votedNo = false
                this.votedYes = true
              } else if (res === 2) {
                this.votedNo = true
                this.votedYes = false
              }
            })
          this.votingContract.canVote(this.question.id, this.currentAccount)
            .then(res => {
              this.canVote = res
            })
        }
      }
    }
  },
  computed: {
    isPassedOrRejected: function () {
      return (parseInt(this.question.yea) / this.question.votingPower > parseFloat(ethers.utils.formatEther(this.question.minAcceptQuorum))) &&
      this.question.yea / (parseInt(this.question.yea) + parseInt(this.question.nay)) > parseFloat(ethers.utils.formatEther(this.question.supportRequired)) ? '\u2713 Passed' : '\u2715 Rejected'
    }
  },
  async created () {
    this.getMessage()
    this.getBarValues()
    this.toHHMMSS(this.question.startDate - Math.floor(Date.now() / 1000) + 86400)
    this.startingExpireValue = this.expire
    this.intervalId = setInterval(() => { this.toHHMMSS(this.question.startDate - Math.floor(Date.now() / 1000) + 86400) }, 1000)
    if (this.currentAccount) {
      this.votingContract.getVoterState(this.question.id, this.currentAccount)
        .then(res => {
          if (res === 0) {
            this.votedNo = false
            this.votedYes = false
          } else if (res === 1) {
            this.votedNo = false
            this.votedYes = true
          } else if (res === 2) {
            this.votedNo = true
            this.votedYes = false
          }
        })
      this.votingContract.canVote(this.question.id, this.currentAccount)
        .then(res => {
          this.canVote = res
        })
    }
  },
  methods: {
    async getMessage () {
      if (this.question.script === '0x00000001') {
        this.questionTitle = this.question.metadata
        return
      }

      const addressVoting = this.votingContract.address.substring(2)
      if (this.question.script.includes(addressVoting)) {
        const method = this.question.script.split(addressVoting)[1].substring(0, 16)
        let methodName = 'Unknown'
        if (method === '000000247c1d0b87') {
          methodName = 'Change required support to'
        } else if (method === '000000245eb24332') {
          methodName = 'Change minimum acceptance quorum to'
        }
        const amount = parseFloat((ethers.utils.formatEther('0x' + this.question.script.substring(this.question.script.length - 64, this.question.script.length)) * 100).toFixed(3))
        this.questionTitle = `${methodName} ${amount}%`
        return
      }

      this.isText = false
      this.questionTitle = 'Unknown method'
    },
    getBarValues () {
      this.yesValue = this.question.yea / this.question.votingPower * 100
      this.noValue = this.question.nay / this.question.votingPower * 100
    },

    async vote (supports) {
      this.loading = true
      try {
        const tx = await this.votingContract.connect(this.provider.getSigner()).vote(
          this.question.id,
          supports,
          true,
          {
            gasPrice: '0'
          }
        )
        await tx.wait()
      } catch (err) {
        console.log(err)
      }
      this.loading = false
      this.$emit('update')
    },

    toHHMMSS (timestamp) {
      this.expired = timestamp <= 0
      if (!this.expired) {
        var hours = Math.floor(timestamp / 3600)
        var minutes = Math.floor((timestamp - (hours * 3600)) / 60)
        var seconds = timestamp - (hours * 3600) - (minutes * 60)

        if (hours > 0) {
          this.time = hours + 'H : ' + minutes + 'M : ' + seconds + 'S'
        } else if (minutes > 0) {
          this.time = minutes + 'M : ' + seconds + 'S'
        } else {
          this.time = seconds + 'S'
        }
        return
      }
      if (this.startingExpireValue === false) {
        this.$emit('update')
      }
      clearInterval(this.intervalId)
    }

  }
}
</script>
<style scoped>
.pdf{
  min-height:250px;
  height:100%;
  border:none;
  width:100%;
}
.rejected{
  color:rgb(255, 105, 105);
}
.passed{
  color:rgb(44, 198, 143);
}
.id{
  font-weight:600;
}
.title{
  text-overflow: ellipsis;
  overflow: hidden;
  margin-top:9px;
  min-height:70px;
 /* height:200px;*/
  margin-right:35px;
  margin-left:35px;
  padding-bottom:4px;
}
.execution{
  margin-top:12px;
  margin-left:34px;
  font-size:15px;
  padding-bottom:6px;
}
.progress{
  margin-top:13px;
  margin-left:35px;
  width:230px;
}
.yes{
    background-color:rgb(44, 198, 143);
}
.no{
    background-color:rgb(255, 105, 105);
}
.buttons{
    width:100%;
}
button{
    transition:0.2s;
    cursor: pointer;
    margin-top:-5px;
    outline:none;
    border:none;
    border-radius:5px;
    color:white;
    font-size:15px;
    height:25px;
    width:60px;
    float:right;
}
.yes:hover{
    background-color:rgb(38, 168, 123);
}
.no:hover{
   background-color:rgb(223, 92, 92);
}
button:disabled{
    cursor: default;
    background-color: rgb(179, 179, 179) !important;
}
.question{
  display:inline-block;
  -webkit-box-shadow: -1px 4px 10px -1px rgba(34, 60, 80, 0.05);
  -moz-box-shadow: -1px 4px 10px -1px rgba(34, 60, 80, 0.05);
  box-shadow: -1px 4px 10px -1px rgba(34, 60, 80, 0.05);
  text-align: left;
  padding-top:15px;
  padding-bottom:15px;
  width:300px;
  margin:0 auto;
  margin-bottom:15px;
  background-color:white;
  border:1px solid rgb(228, 228, 228);
  border-radius:8px;
  margin-left: 10px;
  margin-right: 10px;
  vertical-align: top;

}
.lds-ellipsis {
  display: inline-block;
  position: absolute;
  margin-top:-36px;
  margin-left:-27px;
  width: 60px;
  height: 60px;
}
.lds-ellipsis div {
  position: absolute;
  top: 33px;
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: #fff;
  animation-timing-function: cubic-bezier(0, 1, 1, 0);
}
.lds-ellipsis div:nth-child(1) {
  left: 6px;
  animation: lds-ellipsis1 0.6s infinite;
}
.lds-ellipsis div:nth-child(2) {
  left: 6px;
  animation: lds-ellipsis2 0.6s infinite;
}
.lds-ellipsis div:nth-child(3) {
  left: 24px;
  animation: lds-ellipsis2 0.6s infinite;
}
.lds-ellipsis div:nth-child(4) {
  left: 42px;
  animation: lds-ellipsis3 0.6s infinite;
}
@keyframes lds-ellipsis1 {
  0% {
    transform: scale(0);
  }
  100% {
    transform: scale(1);
  }
}
@keyframes lds-ellipsis3 {
  0% {
    transform: scale(1);
  }
  100% {
    transform: scale(0);
  }
}
@keyframes lds-ellipsis2 {
  0% {
    transform: translate(0, 0);
  }
  100% {
    transform: translate(18px, 0);
  }
}

</style>
